//
// Created by John Griffin on 12/27/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day25Tests: XCTestCase {
    let input = resourceURL(filename: "Day25Input.txt")!.readContents()!

    func testStableExample() {
        var sea = Self.seaParser.parse(example)!
        let result = sea.moveUntilStable()
        XCTAssertEqual(result, 58)
    }

    func testStableInput() {
        var sea = Self.seaParser.parse(input)!
        let result = sea.moveUntilStable()
        XCTAssertEqual(result, 378)
    }
}

extension Day25Tests {
    typealias Index = IndexXY

    struct Sea: CustomStringConvertible {
        var cucumbers: [[Cucumber]]
        let indices: Index.IndexRanges

        init(_ cucumbers: [[Cucumber]]) {
            self.cucumbers = cucumbers
            indices = cucumbers.indexXYRanges()
        }

        var description: String {
            cucumbers.map { row in
                row.map(\.description).joined()
            }.joined(separator: "\n")
        }

        mutating func moveUntilStable() -> Int {
            var moveCount = 0
            var prev = cucumbers
            while true {
                moveHerds()
                moveCount += 1

                if cucumbers == prev {
                    break
                }

                prev = cucumbers
            }

            return moveCount
        }

        mutating func moveHerds() {
            moveHerd(.e)
            moveHerd(.s)
        }

        mutating func moveHerd(_ c: Cucumber) {
            let moves = product(indices.x, indices.y).map { x, y in Index(x, y) }
                .filter { cucumbers[$0] == c }
                .map { ($0, next($0)) }
                .filter { _, to in cucumbers[to] == .empty }

            moves.forEach { from, to in
                cucumbers[to] = c
                cucumbers[from] = .empty
            }
        }

        func next(_ i: Index) -> Index {
            switch cucumbers[i] {
            case .e: return Index(x: (i.x + 1) % indices.x.upperBound, y: i.y)
            case .s: return Index(x: i.x, y: (i.y + 1) % indices.y.upperBound)
            case .empty: fatalError()
            }
        }
    }

    enum Cucumber: Equatable, CustomStringConvertible {
        case e, s, empty

        var description: String {
            switch self {
            case .e: return ">"
            case .s: return "v"
            case .empty: return "."
            }
        }
    }
}

extension Day25Tests {
    var example: String {
        """
        v...>>.vv>
        .vv>>.vv..
        >>.>v>...v
        >>v>>.>.v.
        v>v.vv.v..
        >.>>..v...
        .vv..>.>v.
        v.v..>>v.v
        ....v..v.>
        """
    }

    // MARK: - parser

    static let cucumberParser = OneOfMany(
        ".".utf8.map { Cucumber.empty },
        ">".utf8.map { Cucumber.e },
        "v".utf8.map { Cucumber.s }
    )
    static let seaParser = Many(Many(cucumberParser, atLeast: 1), separator: "\n".utf8)
        .skip(Optional.parser(of: "\n".utf8))
        .skip(End())
        .map { Sea($0) }

    func testParseExample() {
        let input = Self.seaParser.parse(example)!
        XCTAssertNotNil(input)
    }

    func testParseInput() {
        let input = Self.seaParser.parse(input)!
        XCTAssertNotNil(input)
    }
}
