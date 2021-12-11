//
//
// Created by John Griffin on 12/11/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day11Tests: XCTestCase {
    let input = resourceURL(filename: "Day11Input.txt")!.readContents()!

    let example = """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """

    let stepExample = """
    11111
    19991
    19191
    19991
    11111
    """

    static let lineParser = Prefix(1..., while: { $0.isNumber }).utf8
        .map { $0.map { $0.wholeNumberValue! }}
    static let linesParser = Many(lineParser, separator: "\n".utf8)
        .map { Ocean(energies: $0) }

    // MARK: - syncrhonized

    func testSynchronizedExample() {
        let ocean = Self.linesParser.parse(example)!
        let step = ocean.stepUntilSynchronized()
        XCTAssertEqual(step, 195)
    }

    func testSynchronizedInput() {
        let ocean = Self.linesParser.parse(input)!
        let step = ocean.stepUntilSynchronized()
        XCTAssertEqual(step, 235)
    }

    // MARK: - flashCount

    func testFlashCountExample() {
        let ocean = Self.linesParser.parse(example)!
        let totalFlashCount = (0 ..< 100)
            .map { _ in ocean.stepFlashCount() }
            .reduce(0, +)
        XCTAssertEqual(totalFlashCount, 1656)
    }

    func testFlashCountInput() {
        let ocean = Self.linesParser.parse(input)!
        let totalFlashCount = (0 ..< 100)
            .map { _ in ocean.stepFlashCount() }
            .reduce(0, +)
        XCTAssertEqual(totalFlashCount, 1665)
    }

    // MARK: - step

    func testStepExample() {
        let ocean = Self.linesParser.parse(stepExample)!
        let step1 = ocean.stepFlashCount()
        XCTAssertEqual(step1, 9)
        let step2 = ocean.stepFlashCount()
        XCTAssertEqual(step2, 0)
    }

    // MARK: - parse

    func testParseExample() {
        let ocean = Self.linesParser.parse(example)!
        XCTAssertEqual(ocean.energies.count, 10)
        XCTAssertEqual(ocean.energies.last?.count, 10)

        print(ocean)
    }

    func testParseInput() {
        let ocean = Self.linesParser.parse(input)!
        XCTAssertEqual(ocean.energies.count, 10)
        XCTAssertEqual(ocean.energies.last?.count, 10)
    }
}

extension Day11Tests {
    typealias Loc = IndexXY

    class Ocean: CustomStringConvertible {
        var energies: [[Int]]

        let allLocations: [Loc]
        let neighborsOf: Loc.NeighborsOf

        init(energies: [[Int]]) {
            self.energies = energies

            let indexRanges = energies.indexXYRanges()
            self.allLocations = Loc.allIndexXY(indexRanges)
            self.neighborsOf = Loc.neighborsFunc(
                offsets: Loc.diagonalNeighborOffsets,
                isValidIndex: Loc.isValidIndexFunc(indexRanges)
            )
        }

        func stepUntilSynchronized() -> Int {
            let octopusCount = allLocations.count
            var step = 1
            while stepFlashCount() != octopusCount {
                step += 1
            }
            return step
        }

        func stepFlashCount() -> Int {
            var needsFlashing = increaseEnergyForAllOctopi()

            if needsFlashing.isEmpty {
                return 0
            }

            while !needsFlashing.isEmpty {
                needsFlashing = flashOctopi(needsFlashing)
            }

            return resetFlashedCount()
        }

        // bump energy by one and return loc if it needs flashing
        func increaseEnergy(_ loc: Loc) -> Loc? {
            energies[loc] += 1
            return energies[loc] == 10 ? loc : nil
        }

        func increaseEnergyForAllOctopi() -> [Loc] {
            allLocations.compactMap(increaseEnergy)
        }

        func flashOctopi(_ needsFlashing: [Loc]) -> [Loc] {
            needsFlashing.flatMap(flashOctopus)
        }

        func flashOctopus(_ loc: Loc) -> [Loc] {
            neighborsOf(loc).compactMap(increaseEnergy)
        }

        func resetFlashedCount() -> Int {
            var flashCount = 0
            allLocations.forEach { loc in
                guard energies[loc] > 9 else { return }
                flashCount += 1
                energies[loc] = 0
            }
            return flashCount
        }

        var description: String {
            energies.map {
                $0.map { $0 >= 10 ? "*" : "\($0)" }
                    .joined(separator: "")

            }.joined(separator: "\n")
        }
    }
}
