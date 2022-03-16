//
//
// Created by John Griffin on 12/5/21
//

import Foundation

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day05Tests: XCTestCase {
    let input = resourceURL(filename: "Day05Input.txt")!.readContents()!

    let example = """
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
    """

    static let coordinateParser =
        Parse { Coordinate(x: $0, y: $1) } with: {
            Int.parser()
            ","
            Int.parser()
        }

    static let lineParser =
        Parse { Line(from: $0, to: $1) } with: {
            coordinateParser
            " -> "
            coordinateParser
        }

    static let linesParser = Parse {
        Many(atLeast: 1) { lineParser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() {
        let lines = try! Self.linesParser.parse(example)
        XCTAssertEqual(lines.count, 10)
        XCTAssertEqual(lines.last, Line(from: .init(x: 5, y: 5), to: .init(x: 8, y: 2)))
    }

    func testParseInput() {
        let lines = try! Self.linesParser.parse(input)
        XCTAssertEqual(lines.count, 500)
        XCTAssertEqual(lines.last, Line(from: .init(x: 120, y: 156), to: .init(x: 120, y: 630)))
    }

    func testHVExample() {
        let hvLines = try! Self.linesParser.parse(example)
            .filter(\.isHorizontalOrVertical)

        let hvField = Field.fromLines(hvLines)
        XCTAssertEqual(hvField.overlappingCount, 5)
    }

    func testHVFieldInput() {
        let lines = try! Self.linesParser.parse(input)
        let hvLines = lines.filter(\.isHorizontalOrVertical)
        let hvField = Field.fromLines(hvLines)
        XCTAssertEqual(hvField.overlappingCount, 6311)
    }

    func testDiagonalExample() {
        let lines = try! Self.linesParser.parse(example)
        let field = Field.fromLines(lines)
        XCTAssertEqual(field.overlappingCount, 12)
    }

    func testDiagonalInput() {
        let lines = try! Self.linesParser.parse(input)
        let field = Field.fromLines(lines)
        XCTAssertEqual(field.overlappingCount, 19929)
    }
}

extension Day05Tests {
    typealias Coordinate = IndexXY

    struct Line: Equatable, CustomStringConvertible {
        let from, to: Coordinate

        var isHorizontalOrVertical: Bool { (from.x == to.x) || (from.y == to.y) }

        var description: String { "\(from) -> \(to)" }

        func path() -> [Coordinate] {
            let maxLength = max(abs(from.x - to.x), abs(from.y - to.y))
            let step = ((to.x - from.x) / maxLength, (to.y - from.y) / maxLength)

            var path = [Coordinate]()
            var curr = from
            for _ in 0 ... maxLength {
                path.append(curr)
                curr += step
            }

            return path
        }
    }

    struct Field: CustomStringConvertible {
        var field: [[Int]]

        init(_ field: [[Int]]) {
            self.field = field
        }

        subscript(coordinate: Coordinate) -> Int {
            get { field[coordinate.y][coordinate.x] }
            set { field[coordinate.y][coordinate.x] = newValue }
        }

        var overlappingCount: Int {
            field.flatMap { $0 }.filter { $0 > 1 }.count
        }

        var description: String {
            field
                .map { $0.map(String.init).joined(separator: " ") }
                .joined(separator: "\n")
        }

        // MARK: helpers

        static func fromLines(_ lines: [Line]) -> Field {
            let maxXY = lines.flatMap { [$0.from, $0.to] }
                .reduce(Coordinate(x: 0, y: 0)) { result, next in
                    .init(x: max(result.x, next.x),
                          y: max(result.y, next.y))
                }

            let field = lines
                .flatMap { $0.path() }
                .reduce(into: Self.emptyField(maxX: maxXY.x, maxY: maxXY.y)) { field, coordinate in
                    field[coordinate] += 1
                }
            return field
        }

        static func emptyField(maxX: Int, maxY: Int) -> Field {
            let field = (0 ... maxY).map { _ in
                (0 ... maxX).map { _ in 0 }
            }
            return Field(field)
        }
    }
}
