//
//
// Created by John Griffin on 12/9/21
//

@testable import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day09Tests: XCTestCase {
    let input = resourceURL(filename: "Day09Input.txt")!.readContents()!

    let example = """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """

    typealias HeightMap = [[Int]]

    static let heightLine = Prefix(1..., while: { $0.isNumber })
        .map { $0.map { Int(String($0))! } }
    static let heightsParser = Parse {
        Many { heightLine } separator: { "\n" }
        Skip { Optionally { "\n" }}
    }

    func testParseExample() {
        let heights = try! Self.heightsParser.parse(example)
        XCTAssertEqual(heights.count, 5)
        XCTAssertEqual(heights.last, [9, 8, 9, 9, 9, 6, 5, 6, 7, 8])
    }

    func testParseInput() {
        let heights = try! Self.heightsParser.parse(input)
        XCTAssertEqual(heights.count, 100)
        XCTAssertEqual(heights.last?.last, 1)
    }

    func testRiskLevelExample() {
        let heights = try! Self.heightsParser.parse(example)
        let riskLevel = riskLevel(heights)
        XCTAssertEqual(riskLevel, 15)
    }

    func testRiskLevelInput() {
        let heights = try! Self.heightsParser.parse(input)
        let riskLevel = riskLevel(heights)
        XCTAssertEqual(riskLevel, 532)
    }

    func testBasinsExample() {
        let heights = try! Self.heightsParser.parse(example)

        let basinMap = basinMapFrom(heights)
        let basinAddresses = basinMap.reduce(into: [Basin: [Address]]()) { result, next in
            result[next.value, default: []].append(next.key)
        }
        let basinCounts = basinAddresses
            .map { (basin: $0.key, count: $0.value.count) }
            .sorted { lhs, rhs in lhs.count > rhs.count }

        let topThreeCountsProduct = basinCounts.map(\.count).prefix(3).reduce(1, *)
        XCTAssertEqual(topThreeCountsProduct, 1134)
    }

    func testBasinsInput() {
        let heights = try! Self.heightsParser.parse(input)

        let basinMap = basinMapFrom(heights)
        let basinAddresses = basinMap.reduce(into: [Basin: [Address]]()) { result, next in
            result[next.value, default: []].append(next.key)
        }
        let basinCounts = basinAddresses
            .map { (basin: $0.key, count: $0.value.count) }
            .sorted { lhs, rhs in lhs.count > rhs.count }

        let topThreeCountsProduct = basinCounts.map(\.count).prefix(3).reduce(1, *)
        XCTAssertEqual(topThreeCountsProduct, 1_110_780)
    }
}

extension Day09Tests {
    func riskLevel(_ heights: HeightMap) -> Int {
        let lowAddresses = lowAddresses(heights)
        let minHeights = lowAddresses.map { heights[$0.r][$0.c] }

        return minHeights.reduce(0) { result, height in result + 1 + height }
    }

    typealias Address = IndexRC

    func neighborAddresses(_ heights: HeightMap) -> (Address) -> [Address] {
        Address.neighborsFunc(
            offsets: Address.squareNeighborOffsets,
            isValidIndex: Address.isValidIndexFunc(heights.indexRCRanges())
        )
    }

    func lowAddresses(_ heights: HeightMap) -> [Address] {
        let (rows, cols) = (heights.indices, heights.first!.indices)

        let neighborsOf = neighborAddresses(heights)

        func isLowerThanNeighbors(_ address: Address) -> Bool {
            let neighborsLow = neighborsOf(address).map { heights[$0] }.min()!
            return heights[address.r][address.c] < neighborsLow
        }

        return product(rows, cols).map(Address.init).filter(isLowerThanNeighbors)
    }

    typealias Basin = Address
    typealias BasinMap = [Address: Basin]

    func basinMapFrom(_ heights: HeightMap) -> BasinMap {
        let lowAddresses = lowAddresses(heights)

        var bestBasins = lowAddresses.reduce(into: BasinMap()) { result, address in
            result[address] = address
        }

        while true {
            let prevBest = bestBasins
            bestBasins = growBasinMap(heights, basins: bestBasins)
            if bestBasins == prevBest {
                return bestBasins
            }
        }
    }

    func growBasinMap(_ heights: HeightMap, basins: BasinMap) -> BasinMap {
        var updatedBasins = basins
        let (rows, cols) = (heights.indices, heights.first!.indices)

        func h(_ address: Address) -> Int { heights[address.r][address.c] }

        let neighbors = neighborAddresses(heights)

        func neighborBasin(to address: Address) -> Basin? {
            let height = h(address)
            for n in neighbors(address) {
                guard let basin = updatedBasins[n] else { continue }
                if h(n) < height {
                    return basin
                }
            }
            return nil
        }

        product(rows, cols).map(Address.init).forEach { a in
            guard h(a) != 9, updatedBasins[a] == nil else { return }
            if let b = neighborBasin(to: a) {
                updatedBasins[a] = b
            }
        }

        return updatedBasins
    }
}
