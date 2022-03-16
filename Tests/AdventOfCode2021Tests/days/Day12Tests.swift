//
//
// Created by John Griffin on 12/13/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day12Tests: XCTestCase {
    let input = resourceURL(filename: "Day12Input.txt")!.readContents()!

    // MARK: cavePaths

    func testCavePathsTwiceSmallExample() {
        let connections = try! Self.connectionsParser.parse(smallExample)

        let paths = cavePathsToEnd(connections, canRevisitOneSmallCavesTwice)
        let uniquePaths = paths.asSet
        XCTAssertEqual(uniquePaths.count, 36)
    }

    func testCavePathsTwiceBiggerExample() {
        let connections = try! Self.connectionsParser.parse(biggerExample)

        let paths = cavePathsToEnd(connections, canRevisitOneSmallCavesTwice)
        XCTAssertEqual(paths.count, 103)
    }

    func testCavePathsTwiceInput() {
        let connections = try! Self.connectionsParser.parse(input)

        let paths = cavePathsToEnd(connections, canRevisitOneSmallCavesTwice)
        XCTAssertEqual(paths.count, 143_562)
    }

    // MARK: cavePaths

    func testCavePathsSmallExample() {
        let connections = try! Self.connectionsParser.parse(smallExample)

        let paths = cavePathsToEnd(connections, canRevisitSmallCavesOnce)
        XCTAssertEqual(paths.count, 10)
    }

    func testCavePathsBiggerExample() {
        let connections = try! Self.connectionsParser.parse(biggerExample)

        let paths = cavePathsToEnd(connections, canRevisitSmallCavesOnce)
        XCTAssertEqual(paths.count, 19)
    }

    func testCavePathsInput() {
        let connections = try! Self.connectionsParser.parse(input)

        let paths = cavePathsToEnd(connections, canRevisitSmallCavesOnce)
        XCTAssertEqual(paths.count, 4754)
    }

    // MARK: - parser

    func testParser() {
        let connections = try! Self.connectionsParser.parse(smallExample)
        XCTAssertEqual(connections.count, 7)

        let biggerConnections = try! Self.connectionsParser.parse(biggerExample)
        XCTAssertEqual(biggerConnections.count, 10)

        let inputConnections = try! Self.connectionsParser.parse(input)
        XCTAssertEqual(inputConnections.count, 25)
    }

    static let caveNameParser = Prefix(1..., while: { $0.isLetter })
        .map { Cave(name: String($0)) }
    static let connectionParser = Parse { CaveConnection($0, $1) } with: {
        caveNameParser
        "-"
        caveNameParser
    }

    static let connectionsParser = Parse {
        Many(atLeast: 1) { connectionParser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    let smallExample = """
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    """

    let biggerExample = """
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
    """
}

extension Day12Tests {
    typealias CanRevisitCave = (Cave, Path) -> Bool

    func canRevisitSmallCavesOnce(_ c: Cave, _ path: Path) -> Bool {
        guard c.isSmall else { return true }
        return !path.contains(c)
    }

    func canRevisitOneSmallCavesTwice(_ c: Cave, _ path: Path) -> Bool {
        guard c.isSmall else { return true }
        let smallCaves = (path + [c]).filter(\.isSmall)
        return smallCaves.count <= smallCaves.asSet.count + 1
    }

    func cavePathsToEnd(
        _ connections: [CaveConnection],
        _ canRevisitCave: CanRevisitCave
    ) -> [Path] {
        let neighbors = connections.reduce(into: [Cave: [Cave]]()) { result, c in
            if c.1 != .start {
                result[c.0, default: []].append(c.1)
            }
            if c.0 != .start {
                result[c.1, default: []].append(c.0)
            }
        }

        func pathsToEnd(_ curr: Cave, prefix: Path) -> [Path] {
            let pathToCurr = prefix + [curr]
            guard curr != .end else {
                return [pathToCurr]
            }

            let nexts = neighbors[curr]!
                .filter { n in canRevisitCave(n, pathToCurr) }

            return nexts
                .flatMap { n in
                    pathsToEnd(n, prefix: pathToCurr)
                }
        }

        let paths = pathsToEnd(.start, prefix: [])
        return paths
    }

    func path(_ path: Path, hasAll caves: Set<Cave>) -> Bool {
        path.asSet.isSuperset(of: caves)
    }
}

extension Day12Tests {
    struct Cave: Hashable, CustomStringConvertible {
        let name: String

        var description: String { name }
        var isSmall: Bool { name.first!.isLowercase && self != .start && self != .end }

        static let start = Cave(name: "start")
        static let end = Cave(name: "end")
    }

    typealias CaveConnection = (Cave, Cave)
    typealias Path = [Cave]

    func smallCaves(from connections: [CaveConnection]) -> Set<Cave> {
        connections
            .flatMap { c in [c.0, c.1] }
            .filter(\.isSmall)
            .asSet
    }

    func smallCaves(from path: Path) -> Set<Cave> {
        path.filter(\.isSmall).asSet
    }

    func dump(_ path: Path) {
        print(path.map(\.description).joined(separator: ","))
    }

    func dump(_ paths: [Path]) {
        paths.forEach(dump)
    }
}
