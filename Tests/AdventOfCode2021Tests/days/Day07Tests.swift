//
//
// Created by John Griffin on 12/7/21
//

@testable import AdventOfCode2021
import Parsing
import XCTest

final class Day07Tests: XCTestCase {
    let input = resourceURL(filename: "Day07Input.txt")!.readContents()!

    let example = "16,1,2,0,4,2,7,1,2,14"

    let positionsParser = Parse {
        Many { Int.parser() } separator: { "," }
        Skip { Optionally { "\n" }}
    }

    func testParseExample() {
        let postions = try! positionsParser.parse(example)
        XCTAssertEqual(postions, [16, 1, 2, 0, 4, 2, 7, 1, 2, 14])
    }

    func testParseInput() {
        let postions = try! positionsParser.parse(input)
        XCTAssertEqual(postions.count, 1000)
        XCTAssertEqual(postions.last, 241)
    }

    func testBestPositionExample() {
        let positions = try! positionsParser.parse(example)
        let minMax = positions.minAndMax()!
        let range = minMax.min ... minMax.max

        let fuelSums = range.map { p -> (position: Int, fuel: Int) in
            (p, positions.map { abs($0 - p) }.map(fuelForDistance).reduce(0,+))
        }
        let minFuel = fuelSums.min { lhs, rhs in lhs.fuel < rhs.fuel }!

        XCTAssertEqual(minFuel.position, 2)
        XCTAssertEqual(minFuel.fuel, 37)
    }

    func testBestPositionInput() {
        let positions = try! positionsParser.parse(input)
        let minMax = positions.minAndMax()!
        let range = minMax.min ... minMax.max

        let fuelSums = range.map { p -> (position: Int, fuel: Int) in
            (p, positions.map { abs($0 - p) }.map(fuelForDistance).reduce(0,+))
        }
        let minFuel = fuelSums.min { lhs, rhs in lhs.fuel < rhs.fuel }!

        XCTAssertEqual(minFuel.position, 362)
        XCTAssertEqual(minFuel.fuel, 342_534)
    }

    func testBestIncreasingPositionExample() {
        let positions = try! positionsParser.parse(example)
        let minMax = positions.minAndMax()!
        let range = minMax.min ... minMax.max

        let fuelSums = range.map { p -> (position: Int, fuel: Int) in
            (p, positions.map { abs($0 - p) }.map(fuelForDistanceIncreasing).reduce(0,+))
        }
        let minFuel = fuelSums.min { lhs, rhs in lhs.fuel < rhs.fuel }!

        XCTAssertEqual(minFuel.position, 5)
        XCTAssertEqual(minFuel.fuel, 168)
    }

    func testBestIncreasingPositionInput() {
        let positions = try! positionsParser.parse(input)
        let minMax = positions.minAndMax()!
        let range = minMax.min ... minMax.max

        let fuelSums = range.map { p -> (position: Int, fuel: Int) in
            (p, positions.map { abs($0 - p) }.map(fuelForDistanceIncreasing).reduce(0,+))
        }
        let minFuel = fuelSums.min { lhs, rhs in lhs.fuel < rhs.fuel }!

        XCTAssertEqual(minFuel.position, 474)
        XCTAssertEqual(minFuel.fuel, 94_004_208)
    }

    let fuelForDistance = { (distance: Int) in distance }

    let fuelForDistanceIncreasing: (Int) -> Int =
        memoizeRecursive { (distance: Int, recurse: (Int) -> Int) in
            guard distance != 0 else { return 0 }
            return distance * distance - recurse(distance - 1)
        }
}
