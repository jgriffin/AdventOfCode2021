@testable import AdventOfCode2021
import Parsing
import XCTest

final class Day01Tests: XCTestCase {
    let example = """
    199
    200
    208
    210
    200
    207
    240
    269
    260
    263
    """

    let input = resourceURL(filename: "Day01Input.txt")!.readContents()!

    static let depthParser = Int.parser()
    static let depthsParser = Many(depthParser, separator: "\n")

    func testParseExample() throws {
        let depths = Self.depthsParser.parse(example)
        XCTAssertEqual(depths, [199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
    }

    func testParseInput() throws {
        let depths = Self.depthsParser.parse(input)
        XCTAssertEqual(depths?.count, 2000)
        XCTAssertEqual(depths?.last, 4618)
    }

    func testCountIncreasesExample() throws {
        let depths = Self.depthsParser.parse(example)!
        let deltas = depthDeltas(depths: depths)
        let increaseCount = deltas.filter { $0 > 0 }.count
        XCTAssertEqual(increaseCount, 7)
    }

    func testCountIncreasesInput() throws {
        let depths = Self.depthsParser.parse(input)!
        let deltas = depthDeltas(depths: depths)
        let increaseCount = deltas.filter { $0 > 0 }.count
        XCTAssertEqual(increaseCount, 1316)
    }

    func testCountTrippleIncreasesExample() throws {
        let depths = Self.depthsParser.parse(example)!
        let tripples = depthTripples(depths: depths)
        let deltas = depthDeltas(depths: tripples)
        let increaseCount = deltas.filter { $0 > 0 }.count
        XCTAssertEqual(increaseCount, 5)
    }

    func testCountTrippleIncreasesInput() throws {
        let depths = Self.depthsParser.parse(input)!
        let tripples = depthTripples(depths: depths)
        let deltas = depthDeltas(depths: tripples)
        let increaseCount = deltas.filter { $0 > 0 }.count
        XCTAssertEqual(increaseCount, 1344)
    }

    // MARK: - helpers

    func depthDeltas(depths: [Int]) -> [Int] {
        zip(depths.dropFirst(), depths)
            .map { lhs, rhs in lhs - rhs }
    }

    func depthTripples(depths: [Int]) -> [Int] {
        zip(depths, zip(depths.dropFirst(), depths.dropFirst(2)))
            .map { $0 + $1.0 + $1.1 }
    }
}
