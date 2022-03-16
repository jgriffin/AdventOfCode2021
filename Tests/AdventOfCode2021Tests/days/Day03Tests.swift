//
//
// Created by John Griffin on 12/4/21
//

@testable import AdventOfCode2021
import Foundation
import Parsing
import XCTest

final class Day03Tests: XCTestCase {
    let input = resourceURL(filename: "Day03Input.txt")!.readContents()!

    let example = """
    00100
    11110
    10110
    10111
    10101
    01111
    00111
    11100
    10000
    11001
    00010
    01010
    """

    typealias BinaryNumber = [Int]
    static let digitParser = First<Substring>().filter(\.isWholeNumber).map { Int(String($0))! }
    static let bitsParser = Many(atLeast: 1) { digitParser }
    static let inputParser = Parse {
        Many(atLeast: 1) { bitsParser } separator: { "\n" }
        Skip { Many { "\n" } }
        End()
    }

    func testParseExample() throws {
        let numbers = try Self.inputParser.parse(example)
        XCTAssertEqual(numbers.count, 12)
        XCTAssertEqual(numbers.last, [0, 1, 0, 1, 0])
    }

    func testParseInput() throws {
        let numbers = try Self.inputParser.parse(input)
        XCTAssertEqual(numbers.count, 1000)
        XCTAssertEqual(numbers.last, [0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1])
    }

    func testCountsExample() throws {
        let numbers = try Self.inputParser.parse(example)
        let counts = countBitsByPosition(numbers)

        let epsilonBits = counts.map(\.epsilonBit)
        XCTAssertEqual(epsilonBits, [1, 0, 1, 1, 0])
        let epsilon = intFromBits(epsilonBits)
        XCTAssertEqual(epsilon, 22)

        let gammaBits = counts.map(\.gammaBit)
        XCTAssertEqual(gammaBits, [0, 1, 0, 0, 1])
        let gamma: Int = intFromBits(gammaBits)
        XCTAssertEqual(gamma, 9)

        let power = epsilon * gamma
        XCTAssertEqual(power, 198)
    }

    func testCountsInput() throws {
        let numbers = try Self.inputParser.parse(input)
        let counts = countBitsByPosition(numbers)

        let epsilonBits = counts.map(\.epsilonBit)
        XCTAssertEqual(epsilonBits, [0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1])
        let epsilon = intFromBits(epsilonBits)
        XCTAssertEqual(epsilon, 189)

        let gammaBits = counts.map(\.gammaBit)
        XCTAssertEqual(gammaBits, [1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0])
        let gamma: Int = intFromBits(gammaBits)
        XCTAssertEqual(gamma, 3906)

        let power = epsilon * gamma
        XCTAssertEqual(power, 738_234)
    }

    func testFilterExample() throws {
        let numbers = try Self.inputParser.parse(example)

        let firstDigitCounts = countBits(of: numbers, inPostion: 0)
        XCTAssertEqual(firstDigitCounts, .init(zeros: 5, ones: 7))

        XCTAssertEqual(firstDigitCounts.oxygenBit, 1)
        let oxygenFilterd = filter(numbers, withBit: firstDigitCounts.oxygenBit, inPosition: 0)
        XCTAssertEqual(oxygenFilterd.count, 7)

        XCTAssertEqual(firstDigitCounts.scrubberBit, 0)
        let scrubberFilterd = filter(numbers, withBit: firstDigitCounts.scrubberBit, inPosition: 0)
        XCTAssertEqual(scrubberFilterd.count, 5)
    }

    func testFilterWithBitExample() throws {
        let numbers = try Self.inputParser.parse(example)

        let firstDigitCounts = countBits(of: numbers, inPostion: 0)
        XCTAssertEqual(firstDigitCounts, .init(zeros: 5, ones: 7))

        XCTAssertEqual(firstDigitCounts.oxygenBit, 1)
        let oxygenFilterd = filter(numbers, withBit: firstDigitCounts.oxygenBit, inPosition: 0)
        XCTAssertEqual(oxygenFilterd.count, 7)

        XCTAssertEqual(firstDigitCounts.scrubberBit, 0)
        let scrubberFilterd = filter(numbers, withBit: firstDigitCounts.scrubberBit, inPosition: 0)
        XCTAssertEqual(scrubberFilterd.count, 5)
    }

    func testScrubberExample() throws {
        let numbers = try Self.inputParser.parse(example)

        let oxygenResults = filterByBits(
            numbers,
            bitKeyPath: \.oxygenBit,
            fromPosition: 0
        )
        XCTAssertEqual(oxygenResults, [[1, 0, 1, 1, 1]])
        let oxygenRating = intFromBits(oxygenResults.first!)

        let scrubberResults = filterByBits(
            numbers,
            bitKeyPath: \.scrubberBit,
            fromPosition: 0
        )
        XCTAssertEqual(scrubberResults, [[0, 1, 0, 1, 0]])
        let scrubberRating = intFromBits(scrubberResults.first!)

        let lifeSupportRating = oxygenRating * scrubberRating
        XCTAssertEqual(lifeSupportRating, 230)
    }

    func testScrubberInput() throws {
        let numbers = try Self.inputParser.parse(input)

        let oxygenResults = filterByBits(
            numbers,
            bitKeyPath: \.oxygenBit,
            fromPosition: 0
        )
        XCTAssertEqual(oxygenResults, [[0, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1]])
        let oxygenRating = intFromBits(oxygenResults.first!)

        let scrubberResults = filterByBits(
            numbers,
            bitKeyPath: \.scrubberBit,
            fromPosition: 0
        )
        XCTAssertEqual(scrubberResults, [[1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0]])
        let scrubberRating = intFromBits(scrubberResults.first!)

        let lifeSupportRating = oxygenRating * scrubberRating
        XCTAssertEqual(lifeSupportRating, 3_969_126)
    }
}

extension Day03Tests {
    struct BitCounts: Equatable {
        var zeros = 0
        var ones = 0

        var gammaBit: Int { zeros < ones ? 0 : 1 }
        var epsilonBit: Int { otherBit(gammaBit) }

        var oxygenBit: Int { zeros <= ones ? 1 : 0 }
        var scrubberBit: Int { otherBit(oxygenBit) }

        func otherBit(_ b: Int) -> Int { b == 0 ? 1 : 0 }
    }

    func countBitsByPosition(_ numbers: [BinaryNumber]) -> [BitCounts] {
        (0 ..< numbers.first!.count)
            .map { position in
                countBits(of: numbers, inPostion: position)
            }
    }

    func countBits(of numbers: [BinaryNumber], inPostion position: Int) -> BitCounts {
        let ones = numbers.map { $0[position] }.reduce(0, +)
        let zeros = numbers.count - ones

        return BitCounts(
            zeros: zeros,
            ones: ones
        )
    }

    func intFromBits(_ number: BinaryNumber) -> Int {
        number.reduce(0) { result, bit in
            result << 1 + bit
        }
    }

    func filter(
        _ numbers: [BinaryNumber],
        withBit: Int,
        inPosition position: Int
    ) -> [BinaryNumber] {
        numbers.filter { $0[position] == withBit }
    }

    func filterByBits(
        _ numbers: [BinaryNumber],
        bitKeyPath: KeyPath<BitCounts, Int>,
        fromPosition: Int
    ) -> [BinaryNumber] {
        guard numbers.count > 1 else {
            return numbers
        }

        let bitCounts = countBits(of: numbers, inPostion: fromPosition)
        let filterBit = bitCounts[keyPath: bitKeyPath]
        let filteredNumbers = filter(numbers, withBit: filterBit, inPosition: fromPosition)

        return filterByBits(
            filteredNumbers,
            bitKeyPath: bitKeyPath,
            fromPosition: fromPosition + 1
        )
    }
}
