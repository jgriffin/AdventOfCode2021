//
//
// Created by John Griffin on 12/15/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day15Tests: XCTestCase {
    let input = resourceURL(filename: "Day15Input.txt")!.readContents()!

    var example: String {
        """
        1163751742
        1381373672
        2136511328
        3694931569
        7463417111
        1319128137
        1359912421
        3125421639
        1293138521
        2311944581
        """
    }

    func testTotalRisk5xExample() throws {
        let riskMap = try Self.riskMapParser.parse(example)

        let totalRisk = bestPath5xTotalRisk(riskMap)
        XCTAssertEqual(totalRisk, 315)
    }

    func testTotalRisk5xInput() {
        let riskMap = try! Self.riskMapParser.parse(input)

        let totalRisk = bestPath5xTotalRisk(riskMap)
        XCTAssertEqual(totalRisk, 2853)
    }

    // MARK: - total risk

    func testTotalRiskExample() {
        let riskMap = try! Self.riskMapParser.parse(example)

        let totalRisk = bestPathTotalRisk(riskMap)
        XCTAssertEqual(totalRisk, 40)
    }

    func testTotalRiskInput() {
        let riskMap = try! Self.riskMapParser.parse(input)

        let totalRisk = bestPathTotalRisk(riskMap)
        XCTAssertEqual(totalRisk, 503)
    }

    // MARK: - parser

    static let risksParser = Prefix(1..., while: { $0.isNumber }).map { $0.map { $0.wholeNumberValue! }}
    static let riskMapParser = Parse {
        RiskMap($0)
    } with: {
        Many { risksParser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() throws {
        let riskMap = try Self.riskMapParser.parse(example)
        XCTAssertEqual(riskMap.count, 10)
        XCTAssertEqual(riskMap.last?.last, 1)
    }

    func testParseInput() throws {
        let riskMap = try Self.riskMapParser.parse(input)
        XCTAssertEqual(riskMap.count, 100)
        XCTAssertEqual(riskMap.last?.last, 1)
    }
}

extension Day15Tests {
    typealias Risk = Int
    typealias RiskMap = [[Risk]]
    typealias Index = IndexXY

    func bestPath5xTotalRisk(_ riskMap: RiskMap) -> Risk {
        let map1xIndices = riskMap.indexXYRanges()
        let map1xMax = Index(map1xIndices.x.count, map1xIndices.y.count)

        let map5xIndices = Index.IndexRanges(
            x: 0 ..< map1xMax.x * 5,
            y: 0 ..< map1xMax.y * 5
        )

        let neighbors = Index.neighborsFunc(
            offsets: Index.squareNeighborOffsets,
            isValidIndex: Index.isValidIndexFunc(map5xIndices)
        )

        func tiledRisk(_ i: Index) -> Int {
            let modIndex = Index(i.x % map1xMax.x, i.y % map1xMax.y)
            let modRisk = riskMap[modIndex]

            let tileRisk = modRisk + addedTileRisk(i)

            // wraps above 9 to 1!
            let wrappedRisk = (tileRisk - 1) % 9 + 1

            return wrappedRisk
        }

        func tileIndex(_ i: Index) -> Index { Index(i.x / map1xMax.x, i.y / map1xMax.y) }

        func addedTileRisk(_ i: Index) -> Int {
            let ti = tileIndex(i)
            return ti.x + ti.y
        }

        let memoizedHXYCount = memoize { (xyCount: Int) in
            (xyCount / 8) * 5 + (0 ..< (xyCount % 8)).reduce(1,+)
        }

        func h(from: Index, to: Index) -> Int {
            let xCount = to.x - from.x
            let yCount = to.y - from.y
            let xyCount = xCount + yCount
            return memoizedHXYCount(xyCount)
        }

        let solver = AStar(
            neighborsOf: { i in
                neighbors(i).map { n in (n, (), tiledRisk(n)) }
            },
            h: h
        )

        guard let path = solver.findBestPath(
            start: Index.zero,
            goal: Index(map5xIndices.x.last!, map5xIndices.y.last!)
        ) else { fatalError() }

        let totalRisk = path.map(\.c).reduce(0,+)
        return totalRisk
    }

    func bestPathTotalRisk(_ riskMap: RiskMap) -> Risk {
        let mapIndices = riskMap.indexXYRanges()
        let neighbors = Index.neighborsFunc(
            offsets: Index.squareNeighborOffsets,
            isValidIndex: Index.isValidIndexFunc(mapIndices)
        )

        let solver = AStar(
            neighborsOf: { i in
                neighbors(i).map { n in (n, (), riskMap[n]) }
            },
            h: Index.manhattanDistance
        )

        guard let path = solver.findBestPath(
            start: Index.zero,
            goal: Index(mapIndices.x.last!, mapIndices.y.last!)
        ) else { fatalError() }

        let totalRisk = path.map(\.c).reduce(0,+)
        return totalRisk
    }
}
