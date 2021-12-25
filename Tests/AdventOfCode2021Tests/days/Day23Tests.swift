//
// Created by John Griffin on 12/23/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day23Tests: XCTestCase {
    func testSolve4Example() {
        let start = Self.input4Parser.parse(example4)!

        let solver = AStar(
            neighborsOf: { (state: State) in
                state.moves4().map { m in (state.applyingMove(m), m, state.costOfMove(m)) }
            },
            h: { state, _ in state.heuristic4() }
        )

        let path = solver.findBestPath(start: start, goal: .goalState4)!

        // print(path.map { "\($0)" }.joined(separator: "\n"))
        XCTAssertEqual(path.map(\.c).reduce(0,+), 44169)
    }

    func testSolve4Input() {
        let start = Self.input4Parser.parse(input4)!

        let solver = AStar(
            neighborsOf: { (state: State) in
                state.moves4().map { m in (state.applyingMove(m), m, state.costOfMove(m)) }
            },
            h: { state, _ in state.heuristic4() }
        )

        let path = solver.findBestPath(start: start, goal: .goalState4)!

        // print(path.map { "\($0)" }.joined(separator: "\n"))
        XCTAssertEqual(path.map(\.c).reduce(0,+), 54200)
    }

    func testSolveExample() {
        let start = Self.input2Parser.parse(example)!

        let solver = AStar(
            neighborsOf: { (state: State) in
                state.moves2().map { m in (state.applyingMove(m), m, state.costOfMove(m)) }
            },
            h: { state, _ in state.heuristic2() }
        )

        let path = solver.findBestPath(start: start, goal: .goalState2)!

        // print(path.map { "\($0)" }.joined(separator: "\n"))
        XCTAssertEqual(path.map(\.c).reduce(0,+), 12521)
    }

    func testSolveInput() {
        let start = Self.input2Parser.parse(Self.input)!

        let solver = AStar(
            neighborsOf: { (state: State) in
                state.moves2().map { m in (state.applyingMove(m), m, state.costOfMove(m)) }
            },
            h: { state, _ in state.heuristic2() }
        )

        let path = solver.findBestPath(start: start, goal: .goalState2)!

        // print(path.map { "\($0)" }.joined(separator: "\n"))
        XCTAssertEqual(path.map(\.c).reduce(0,+), 13556)
    }

    func testStateMoves() {
        let state = Self.input2Parser.parse(example)!
        let moves = state.moves2()
        let newStates = moves.map { m in state.applyingMove(m) }
        // print(newStates.map(\.description).joined(separator: "\n"))
        XCTAssertEqual(newStates.count, 28)
    }
}

extension Day23Tests {
    struct State: Hashable, CustomStringConvertible {
        var occupants: [Slot: APod]

        func applyingMove(_ m: Move) -> State {
            assert(meetsMoveRequirements(m))
            var newOccupants = occupants
            newOccupants[m.to] = occupants[m.from]!
            newOccupants[m.from] = nil

            return State(occupants: newOccupants)
        }

        func moves2() -> [Move] {
            Self.finalSlots2AndOccupant
                .reduce(into: [Move]()) { moves, slotsAndO in
                    let (o1, o2, o) = (occupants[slotsAndO.s1], occupants[slotsAndO.s2], slotsAndO.o)

                    switch (o1, o2) {
                    case (o, o):
                        break
                    case (_, .some):
                        // move out s2
                        moves += Move.outFrom2[slotsAndO.s2]!
                            .filter(meetsMoveRequirements)
                    case (o, nil):
                        // move into s2
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves2.first { m in m.from == from && m.to == slotsAndO.s2 }! }
                            .filter(meetsMoveRequirements)
                    case (.some, nil):
                        // move s1 out
                        moves += Move.outFrom2[slotsAndO.s1]!.filter(meetsMoveRequirements)
                    case (nil, nil):
                        // move into s1
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves2.first { m in m.from == from && m.to == slotsAndO.s1 }! }
                            .filter(meetsMoveRequirements)
                    }
                }
        }

        func moves4() -> [Move] {
            Self.finalSlots4AndOccupant
                .reduce(into: [Move]()) { moves, slotsAndO in
                    let (o00, o0, o1, o2, o) =
                        (occupants[slotsAndO.s00], occupants[slotsAndO.s0], occupants[slotsAndO.s1], occupants[slotsAndO.s2], slotsAndO.o)

                    switch (o00, o0, o1, o2) {
                    case (o, o, o, o):
                        break

                    case (_, _, _, .some):
                        // move out s2
                        moves += Move.outFrom4[slotsAndO.s2]!
                            .filter(meetsMoveRequirements)
                    case (o, o, o, nil):
                        // move into s2
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves4.first { m in m.from == from && m.to == slotsAndO.s2 }! }
                            .filter(meetsMoveRequirements)

                    case (_, _, .some, nil):
                        // move s1 out
                        moves += Move.outFrom4[slotsAndO.s1]!.filter(meetsMoveRequirements)
                    case (o, o, nil, nil):
                        // move into s1
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves4.first { m in m.from == from && m.to == slotsAndO.s1 }! }
                            .filter(meetsMoveRequirements)

                    case (_, .some, nil, nil):
                        // move s0 out
                        moves += Move.outFrom4[slotsAndO.s0]!.filter(meetsMoveRequirements)
                    case (o, nil, nil, nil):
                        // move into s0
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves4.first { m in m.from == from && m.to == slotsAndO.s0 }! }
                            .filter(meetsMoveRequirements)

                    case (.some, nil, nil, nil):
                        // move s00 out
                        moves += Move.outFrom4[slotsAndO.s00]!.filter(meetsMoveRequirements)
                    case (nil, nil, nil, nil):
                        // move into s00
                        moves += Slot.hallwaySlots.filter { occupants[$0] == o }
                            .map { from in Move.inMoves4.first { m in m.from == from && m.to == slotsAndO.s00 }! }
                            .filter(meetsMoveRequirements)
                    }
                }
        }

        func meetsMoveRequirements(_ m: Move) -> Bool {
            (occupants[m.to] == nil) && m.thru.allSatisfy { s in occupants[s] == nil }
        }

        func costOfMove(_ m: Move) -> Int {
            m.steps * occupants[m.from]!.stepEnergy
        }

        func heuristic2() -> Int {
            Self.finalSlots2AndOccupant
                .reduce(into: 0) { result, slotsAndO in
                    let (o1, o2, o) = (occupants[slotsAndO.s1], occupants[slotsAndO.s2], slotsAndO.o)

                    if o1 != o {
                        let moveOutCost = 3 * (o1?.stepEnergy ?? 0)
                        let moveInCost = 3 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }

                    if o2 != o {
                        let moveOutCost = 3 * (o2?.stepEnergy ?? 0)
                        let moveInCost = 3 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }
                }
        }

        func heuristic4() -> Int {
            Self.finalSlots4AndOccupant
                .reduce(into: 0) { result, slotsAndO in
                    let (o00, o0, o1, o2, o) =
                        (occupants[slotsAndO.s00], occupants[slotsAndO.s0], occupants[slotsAndO.s1], occupants[slotsAndO.s2], slotsAndO.o)

                    if o00 != o {
                        let moveOutCost = 5 * (o00?.stepEnergy ?? 0)
                        let moveInCost = 5 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }

                    if o0 != o {
                        let moveOutCost = 4 * (o0?.stepEnergy ?? 0)
                        let moveInCost = 4 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }

                    if o1 != o {
                        let moveOutCost = 3 * (o1?.stepEnergy ?? 0)
                        let moveInCost = 3 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }

                    if o2 != o {
                        let moveOutCost = 2 * (o2?.stepEnergy ?? 0)
                        let moveInCost = 2 * slotsAndO.o.stepEnergy
                        result += moveOutCost + moveInCost
                    }
                }
        }

        var description: String {
            let s: [String] = [
                Slot.hallwaySlots.map { s in occupants[s]?.rawValue ?? "." }.joined(),
                Slot.finalSlots2.map { s in occupants[s]?.rawValue ?? "." }.joined(),
                Slot.finalSlots1.map { s in occupants[s]?.rawValue ?? "." }.joined(),
                Slot.finalSlots0.map { s in occupants[s]?.rawValue ?? "." }.joined(),
                Slot.finalSlots00.map { s in occupants[s]?.rawValue ?? "." }.joined(),
            ]
            return s.joined(separator: " ")
        }

        static let goalState2 = State(occupants:
            occupantsFrom(s2: Self.finalOccupants, s1: Self.finalOccupants, s0: [], s00: []))
        static let goalState4 = State(occupants:
            occupantsFrom(s2: Self.finalOccupants, s1: Self.finalOccupants, s0: Self.finalOccupants, s00: Self.finalOccupants))

        static func occupantsFrom(s2: [APod], s1: [APod], s0: [APod], s00: [APod]) -> [Slot: APod] {
            Dictionary(uniqueKeysWithValues:
                zip(Slot.finalSlots2 + Slot.finalSlots1 + Slot.finalSlots0 + Slot.finalSlots00, s2 + s1 + s0 + s00)
            )
        }

        static var finalOccupants: [APod] = [.a, .b, .c, .d]
        static var finalSlots2AndOccupant = zip(zip(Slot.finalSlots1, Slot.finalSlots2), finalOccupants)
            .map { (s1: $0.0.0, s2: $0.0.1, o: $0.1) }
        static var finalSlots4AndOccupant = zip(zip(zip(Slot.finalSlots00, Slot.finalSlots0),
                                                    zip(Slot.finalSlots1, Slot.finalSlots2)),
                                                finalOccupants)
            .map { (s00: $0.0.0.0, s0: $0.0.0.1, s1: $0.0.1.0, s2: $0.0.1.1, o: $0.1) }
    }
}

extension Day23Tests {
    enum APod: String, Hashable {
        case a, b, c, d

        var stepEnergy: Int {
            switch self {
            case .a: return 1
            case .b: return 10
            case .c: return 100
            case .d: return 1000
            }
        }
    }

    enum Slot: String, Hashable {
        case h1, h2, h3, h4, h5, h6, h7
        case a1, a2, b1, b2, c1, c2, d1, d2
        case a0, a00, b0, b00, c0, c00, d0, d00

        static let hallwaySlots: [Slot] = [.h1, .h2, .h3, .h4, .h5, .h6, .h7]
        static var finalSlots2: [Slot] = [.a2, .b2, .c2, .d2]
        static var finalSlots1: [Slot] = [.a1, .b1, .c1, .d1]
        static var finalSlots0: [Slot] = [.a0, .b0, .c0, .d0]
        static var finalSlots00: [Slot] = [.a00, .b00, .c00, .d00]
    }

    struct Move: CustomStringConvertible {
        let from: Slot
        let to: Slot
        let thru: Set<Slot>
        let steps: Int

        var description: String {
            "f:\(from) to:\(to)"
        }

        static let outFrom2 = Dictionary(
            grouping: Day23Tests.out1Moves + Day23Tests.out2Moves,
            by: { $0.from }
        )

        static let outFrom4 = Dictionary(
            grouping: Day23Tests.out00Moves + Day23Tests.out0Moves + Day23Tests.out1Moves + Day23Tests.out2Moves,
            by: { $0.from }
        )

        static let inMoves2 = (Day23Tests.out1Moves + Day23Tests.out2Moves)
            .map { m in Move(from: m.to, to: m.from, thru: m.thru, steps: m.steps) }

        static let inMoves4 = (Day23Tests.out00Moves + Day23Tests.out0Moves + Day23Tests.out1Moves + Day23Tests.out2Moves)
            .map { m in Move(from: m.to, to: m.from, thru: m.thru, steps: m.steps) }
    }

    // h1 h2    h3    h4    h5    h6 h7
    //       a2    b2    c2    d2
    //       a1    b1    c1    d1

    static let out2Moves: [Move] = [
        .init(from: .a2, to: .h1, thru: [.h2], steps: 3),
        .init(from: .a2, to: .h2, thru: [], steps: 2),
        .init(from: .a2, to: .h3, thru: [], steps: 2),
        .init(from: .a2, to: .h4, thru: [.h3], steps: 4),
        .init(from: .a2, to: .h5, thru: [.h3, .h4], steps: 6),
        .init(from: .a2, to: .h6, thru: [.h3, .h4, .h5], steps: 8),
        .init(from: .a2, to: .h7, thru: [.h3, .h4, .h5, .h6], steps: 9),

        .init(from: .b2, to: .h1, thru: [.h2, .h3], steps: 5),
        .init(from: .b2, to: .h2, thru: [.h3], steps: 4),
        .init(from: .b2, to: .h3, thru: [], steps: 2),
        .init(from: .b2, to: .h4, thru: [], steps: 2),
        .init(from: .b2, to: .h5, thru: [.h4], steps: 4),
        .init(from: .b2, to: .h6, thru: [.h4, .h5], steps: 6),
        .init(from: .b2, to: .h7, thru: [.h4, .h5, .h6], steps: 7),

        .init(from: .c2, to: .h1, thru: [.h2, .h3, .h4], steps: 7),
        .init(from: .c2, to: .h2, thru: [.h3, .h4], steps: 6),
        .init(from: .c2, to: .h3, thru: [.h4], steps: 4),
        .init(from: .c2, to: .h4, thru: [], steps: 2),
        .init(from: .c2, to: .h5, thru: [], steps: 2),
        .init(from: .c2, to: .h6, thru: [.h5], steps: 4),
        .init(from: .c2, to: .h7, thru: [.h5, .h6], steps: 5),

        .init(from: .d2, to: .h1, thru: [.h2, .h3, .h4, .h5], steps: 9),
        .init(from: .d2, to: .h2, thru: [.h3, .h4, .h5], steps: 8),
        .init(from: .d2, to: .h3, thru: [.h4, .h5], steps: 6),
        .init(from: .d2, to: .h4, thru: [.h5], steps: 4),
        .init(from: .d2, to: .h5, thru: [], steps: 2),
        .init(from: .d2, to: .h6, thru: [], steps: 2),
        .init(from: .d2, to: .h7, thru: [.h6], steps: 3),
    ]

    static let out1Moves: [Move] = [
        .init(from: .a1, to: .h1, thru: [.a2, .h2], steps: 4),
        .init(from: .a1, to: .h2, thru: [.a2], steps: 3),
        .init(from: .a1, to: .h3, thru: [.a2], steps: 3),
        .init(from: .a1, to: .h4, thru: [.a2, .h3], steps: 5),
        .init(from: .a1, to: .h5, thru: [.a2, .h3, .h4], steps: 7),
        .init(from: .a1, to: .h6, thru: [.a2, .h3, .h4, .h5], steps: 9),
        .init(from: .a1, to: .h7, thru: [.a2, .h3, .h4, .h5, .h6], steps: 10),

        .init(from: .b1, to: .h1, thru: [.b2, .h2, .h3], steps: 6),
        .init(from: .b1, to: .h2, thru: [.b2, .h3], steps: 5),
        .init(from: .b1, to: .h3, thru: [.b2], steps: 3),
        .init(from: .b1, to: .h4, thru: [.b2], steps: 3),
        .init(from: .b1, to: .h5, thru: [.b2, .h4], steps: 5),
        .init(from: .b1, to: .h6, thru: [.b2, .h4, .h5], steps: 7),
        .init(from: .b1, to: .h7, thru: [.b2, .h4, .h5, .h6], steps: 8),

        .init(from: .c1, to: .h1, thru: [.c2, .h2, .h3, .h4], steps: 8),
        .init(from: .c1, to: .h2, thru: [.c2, .h3, .h4], steps: 7),
        .init(from: .c1, to: .h3, thru: [.c2, .h4], steps: 5),
        .init(from: .c1, to: .h4, thru: [.c2], steps: 3),
        .init(from: .c1, to: .h5, thru: [.c2], steps: 3),
        .init(from: .c1, to: .h6, thru: [.c2, .h5], steps: 5),
        .init(from: .c1, to: .h7, thru: [.c2, .h5, .h6], steps: 6),

        .init(from: .d1, to: .h1, thru: [.d2, .h2, .h3, .h4, .h5], steps: 10),
        .init(from: .d1, to: .h2, thru: [.d2, .h3, .h4, .h5], steps: 9),
        .init(from: .d1, to: .h3, thru: [.d2, .h4, .h5], steps: 7),
        .init(from: .d1, to: .h4, thru: [.d2, .h5], steps: 5),
        .init(from: .d1, to: .h5, thru: [.d2], steps: 3),
        .init(from: .d1, to: .h6, thru: [.d2], steps: 3),
        .init(from: .d1, to: .h7, thru: [.d2, .h6], steps: 4),
    ]

    static let out0Moves: [Move] = [
        .init(from: .a0, to: .h1, thru: [.a1, .a2, .h2], steps: 5),
        .init(from: .a0, to: .h2, thru: [.a1, .a2], steps: 4),
        .init(from: .a0, to: .h3, thru: [.a1, .a2], steps: 4),
        .init(from: .a0, to: .h4, thru: [.a1, .a2, .h3], steps: 6),
        .init(from: .a0, to: .h5, thru: [.a1, .a2, .h3, .h4], steps: 8),
        .init(from: .a0, to: .h6, thru: [.a1, .a2, .h3, .h4, .h5], steps: 10),
        .init(from: .a0, to: .h7, thru: [.a1, .a2, .h3, .h4, .h5, .h6], steps: 11),

        .init(from: .b0, to: .h1, thru: [.b1, .b2, .h2, .h3], steps: 7),
        .init(from: .b0, to: .h2, thru: [.b1, .b2, .h3], steps: 6),
        .init(from: .b0, to: .h3, thru: [.b1, .b2], steps: 4),
        .init(from: .b0, to: .h4, thru: [.b1, .b2], steps: 4),
        .init(from: .b0, to: .h5, thru: [.b1, .b2, .h4], steps: 6),
        .init(from: .b0, to: .h6, thru: [.b1, .b2, .h4, .h5], steps: 8),
        .init(from: .b0, to: .h7, thru: [.b1, .b2, .h4, .h5, .h6], steps: 9),

        .init(from: .c0, to: .h1, thru: [.c1, .c2, .h2, .h3, .h4], steps: 9),
        .init(from: .c0, to: .h2, thru: [.c1, .c2, .h3, .h4], steps: 8),
        .init(from: .c0, to: .h3, thru: [.c1, .c2, .h4], steps: 6),
        .init(from: .c0, to: .h4, thru: [.c1, .c2], steps: 4),
        .init(from: .c0, to: .h5, thru: [.c1, .c2], steps: 4),
        .init(from: .c0, to: .h6, thru: [.c1, .c2, .h5], steps: 6),
        .init(from: .c0, to: .h7, thru: [.c1, .c2, .h5, .h6], steps: 7),

        .init(from: .d0, to: .h1, thru: [.d1, .d2, .h2, .h3, .h4, .h5], steps: 11),
        .init(from: .d0, to: .h2, thru: [.d1, .d2, .h3, .h4, .h5], steps: 10),
        .init(from: .d0, to: .h3, thru: [.d1, .d2, .h4, .h5], steps: 8),
        .init(from: .d0, to: .h4, thru: [.d1, .d2, .h5], steps: 6),
        .init(from: .d0, to: .h5, thru: [.d1, .d2], steps: 4),
        .init(from: .d0, to: .h6, thru: [.d1, .d2], steps: 4),
        .init(from: .d0, to: .h7, thru: [.d1, .d2, .h6], steps: 5),
    ]

    static let out00Moves: [Move] = [
        .init(from: .a00, to: .h1, thru: [.a0, .a1, .a2, .h2], steps: 6),
        .init(from: .a00, to: .h2, thru: [.a0, .a1, .a2], steps: 5),
        .init(from: .a00, to: .h3, thru: [.a0, .a1, .a2], steps: 5),
        .init(from: .a00, to: .h4, thru: [.a0, .a1, .a2, .h3], steps: 7),
        .init(from: .a00, to: .h5, thru: [.a0, .a1, .a2, .h3, .h4], steps: 9),
        .init(from: .a00, to: .h6, thru: [.a0, .a1, .a2, .h3, .h4, .h5], steps: 11),
        .init(from: .a00, to: .h7, thru: [.a0, .a1, .a2, .h3, .h4, .h5, .h6], steps: 12),

        .init(from: .b00, to: .h1, thru: [.b0, .b1, .b2, .h2, .h3], steps: 8),
        .init(from: .b00, to: .h2, thru: [.b0, .b1, .b2, .h3], steps: 7),
        .init(from: .b00, to: .h3, thru: [.b0, .b1, .b2], steps: 5),
        .init(from: .b00, to: .h4, thru: [.b0, .b1, .b2], steps: 5),
        .init(from: .b00, to: .h5, thru: [.b0, .b1, .b2, .h4], steps: 7),
        .init(from: .b00, to: .h6, thru: [.b0, .b1, .b2, .h4, .h5], steps: 9),
        .init(from: .b00, to: .h7, thru: [.b0, .b1, .b2, .h4, .h5, .h6], steps: 10),

        .init(from: .c00, to: .h1, thru: [.c0, .c1, .c2, .h2, .h3, .h4], steps: 10),
        .init(from: .c00, to: .h2, thru: [.c0, .c1, .c2, .h3, .h4], steps: 9),
        .init(from: .c00, to: .h3, thru: [.c0, .c1, .c2, .h4], steps: 7),
        .init(from: .c00, to: .h4, thru: [.c0, .c1, .c2], steps: 5),
        .init(from: .c00, to: .h5, thru: [.c0, .c1, .c2], steps: 5),
        .init(from: .c00, to: .h6, thru: [.c0, .c1, .c2, .h5], steps: 7),
        .init(from: .c00, to: .h7, thru: [.c0, .c1, .c2, .h5, .h6], steps: 8),

        .init(from: .d00, to: .h1, thru: [.d0, .d1, .d2, .h2, .h3, .h4, .h5], steps: 12),
        .init(from: .d00, to: .h2, thru: [.d0, .d1, .d2, .h3, .h4, .h5], steps: 11),
        .init(from: .d00, to: .h3, thru: [.d0, .d1, .d2, .h4, .h5], steps: 9),
        .init(from: .d00, to: .h4, thru: [.d0, .d1, .d2, .h5], steps: 7),
        .init(from: .d00, to: .h5, thru: [.d0, .d1, .d2], steps: 5),
        .init(from: .d00, to: .h6, thru: [.d0, .d1, .d2], steps: 5),
        .init(from: .d00, to: .h7, thru: [.d0, .d1, .d2, .h6], steps: 6),
    ]
}

extension Day23Tests {
    static let input = resourceURL(filename: "Day23Input.txt")!.readContents()!

    var example: String {
        """
        #############
        #...........#
        ###B#C#B#D###
          #A#D#C#A#
          #########
        """
    }

    var example4: String {
        """
        #############
        #...........#
        ###B#C#B#D###
          #D#C#B#A#
          #D#B#A#C#
          #A#D#C#A#
          #########
        """
    }

    var input4: String {
        """
        #############
        #...........#
        ###C#D#A#B###
          #D#C#B#A#
          #D#B#A#C#
          #B#A#D#C#
          #########
        """
    }

    // MARK: - parser

    static let aPodParser = OneOfMany("A".utf8.map { APod.a },
                                      "B".utf8.map { APod.b },
                                      "C".utf8.map { APod.c },
                                      "D".utf8.map { APod.d })
    static let fourPodsParser = Many(aPodParser, atLeast: 4, atMost: 4, separator: "#".utf8)

    static let headerParser = "#############\n#...........#\n".utf8
    static let s2Parser = Skip("###".utf8).take(fourPodsParser).skip("###".utf8)
    static let s1Parser = Skip("  #".utf8).take(fourPodsParser).skip("#".utf8)

    static let input2Parser = Skip(headerParser)
        .take(s2Parser).skip("\n".utf8)
        .take(s1Parser).skip("\n".utf8)
        .map { s2, s1 in State(occupants: State.occupantsFrom(s2: s2, s1: s1, s0: [], s00: [])) }

    static let input4Parser = Skip(headerParser)
        .take(s2Parser).skip("\n".utf8)
        .take(s1Parser).skip("\n".utf8)
        .take(s1Parser).skip("\n".utf8)
        .take(s1Parser).skip("\n".utf8)
        .map { s2, s1, s0, s00 in State(occupants: State.occupantsFrom(s2: s2, s1: s1, s0: s0, s00: s00)) }

    func testParseExample() {
        let result = Self.input2Parser.parse(example)!
        XCTAssertEqual("\(result)", "....... bcbd adca .... ....")
    }

    func testParseInput() {
        let result = Self.input2Parser.parse(Self.input)!
        XCTAssertEqual("\(result)", "....... cdab badc .... ....")
    }

    func testParseExample4() {
        let result = Self.input4Parser.parse(example4)!
        XCTAssertEqual("\(result)", "....... bcbd dcba dbac adca")
    }

    func testParseInput4() {
        let result = Self.input4Parser.parse(input4)!
        XCTAssertEqual("\(result)", "....... cdab dcba dbac badc")
    }
}
