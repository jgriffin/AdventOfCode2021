//
//
// Created by John Griffin on 12/17/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day17Tests: XCTestCase {
    let input = resourceURL(filename: "Day17Input.txt")!.readContents()!
    let example = "target area: x=20..30, y=-10..-5"
    let exampleTarget = TargetRange(x: 20 ... 30, y: -10 ... -5)

    // MARK: - parser

    static let intParser = Int.parser(of: Substring.self)
    static let rangeParser = Parse { $0 ... $1 } with: { intParser; ".."; intParser }
    static let inputParser = Parse { TargetRange(x: $0, y: $1) } with: {
        Skip { "target area: x=" }
        rangeParser
        ", y="
        rangeParser
        Skip { Optionally { "\n" } }
    }

    func testHighestVelocityExample() {
        let target = exampleTarget
        let highest = velocityWithHighestX(target: target)
        XCTAssertEqual(highest.v, Velocity(6, 9))
        XCTAssertEqual(highest.maxHeight, 45)
        XCTAssertEqual(highest.totalHits, 112)
    }

    func testHighestVelocityInput() {
        let target = TargetRange(x: 217 ... 240, y: -126 ... -69)
        let highest = velocityWithHighestX(target: target)
        XCTAssertEqual(highest.v, Velocity(21, 125))
        XCTAssertEqual(highest.maxHeight, 7875)
        XCTAssertEqual(highest.totalHits, 2321)
    }

    // MARK: example

    func testVelocityExamples() {
        let target = exampleTarget

        let result = launchProbe(velocity: .init(7, 2), target: target)
        XCTAssertEqual(result.enteredTargetAt, .init(28, -7))

        let result2 = launchProbe(velocity: .init(6, 3), target: target)
        XCTAssertEqual(result2.enteredTargetAt, .init(21, -9))

        let result3 = launchProbe(velocity: .init(9, 0), target: target)
        XCTAssertEqual(result3.enteredTargetAt, .init(30, -6))

        let result4 = launchProbe(velocity: .init(7, -4), target: target)
        XCTAssertEqual(result4.enteredTargetAt, nil)
    }

    // MARK: parsing

    func testParseExample() {
        let ranges = try! Self.inputParser.parse(example)
        XCTAssertEqual(ranges, TargetRange(x: 20 ... 30, y: -10 ... -5))
    }

    func testParseInput() {
        let ranges = try! Self.inputParser.parse(input)
        XCTAssertEqual(ranges, TargetRange(x: 217 ... 240, y: -126 ... -69))
    }
}

extension Day17Tests {
    func velocityWithHighestX(target: TargetRange) -> (v: Velocity, maxHeight: Int, totalHits: Int) {
        let hits = product(1 ... target.x.upperBound,
                           target.y.lowerBound ... 150)
            .map { Velocity(x: $0, y: $1) }
            .compactMap { v -> (v: Velocity, maxHeight: Int, p: Path)? in
                let result = launchProbe(velocity: v, target: target)

                guard result.enteredTargetAt != nil else { return nil }
                return (v: v, maxHeight: result.path.map(\.y).max()!, p: result.path)
            }

        // hits.forEach { print("\($0)") }

        let highest = hits.max { lhs, rhs in lhs.maxHeight < rhs.maxHeight }!
        return (v: highest.v, maxHeight: highest.maxHeight, totalHits: hits.count)
    }

    typealias Position = IndexXY
    typealias Path = [Position]
    typealias Velocity = Position
    typealias PositionAndVelocity = (p: Position, v: Velocity)

    struct TargetRange: Equatable {
        let x, y: ClosedRange<Int>

        enum CheckResult: Equatable {
            case inTarget
            case outsideTarget
            case beyondXRange
            case belowYRange
        }

        func check(_ p: Position) -> CheckResult {
            if x.contains(p.x), y.contains(p.y) {
                return .inTarget
            }
            if p.x > x.upperBound {
                return .beyondXRange
            }
            if p.y < y.lowerBound {
                return .belowYRange
            }
            return .outsideTarget
        }
    }

    typealias ProbeResult = (enteredTargetAt: Position?, path: Path)

    func launchProbe(
        velocity: Velocity,
        target: TargetRange
    ) -> ProbeResult {
        var pv = PositionAndVelocity(p: .zero, v: velocity)
        var path = [Position]()

        while true {
            pv = step(pv)
            path.append(pv.p)

            switch target.check(pv.p) {
            case .inTarget: return (pv.p, path)
            case .beyondXRange: return (nil, path)
            case .belowYRange: return (nil, path)
            case .outsideTarget: break
            }
        }
    }

    func step(_ pv: PositionAndVelocity) -> PositionAndVelocity {
        let p = pv.p + pv.v

        let vx: Int = {
            switch pv.v.x {
            case 0: return 0
            case let x where x > 0: return x - 1
            case let x where x < 0: return x + 1
            default: fatalError()
            }
        }()

        let vp = pv.v.y - 1

        return PositionAndVelocity(p: p, v: .init(vx, vp))
    }
}
