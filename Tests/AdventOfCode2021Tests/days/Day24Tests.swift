//
// Created by John Griffin on 12/24/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day24Tests: XCTestCase {
    func testMaxMemoized() {
        let parts = try! Self.monadParser.parse(Self.input).parts
        let solver = makeMaxSolver(parts)

        let s = solver(.init(iPart: 0, z: 0))!
            .reduce(0) { result, d in result * 10 + d }
        XCTAssertEqual(s, 96_929_994_293_996)
    }

    func testMinMemoized() {
        let parts = try! Self.monadParser.parse(Self.input).parts
        let solver = makeMinSolver(parts)

        let s = solver(.init(iPart: 0, z: 0))!
            .reduce(0) { result, d in result * 10 + d }
        XCTAssertEqual(s, 41_811_761_181_141)
    }

    func testMonadPartSignatures() {
        let monad = try! Self.monadParser.parse(Self.input)
        let parts = monad.parts

        parts.enumerated().forEach { i, part in
            print(i, part.signature)
        }
    }

    func string26(_ i: Int, width: Int = 26) -> String {
        var digits = [Int]()
        var i = i

        while i != 0 {
            digits.append(i % width)
            i = i / width
        }

        return digits.reversed().map { "\($0)" }.joined(separator: ",")
    }
}

extension Day24Tests {
    struct SolverInputs: Hashable {
        let iPart: Int
        let z: Int
    }

    typealias Solver = (SolverInputs) -> [Int]?

    func makeMaxSolver(_ parts: [Monad]) -> Solver {
        memoizeRecursive { input, recurse in
            guard input.iPart < 14 else {
                return input.z == 0 ? [] : nil
            }

            let part = parts[input.iPart]
            let sig = part.signature

            for d in stride(from: 9, to: 1, by: -1) {
                if sig.pop, d != (input.z % 26) + sig.p {
                    continue
                }

                let z = parts[input.iPart].runOn(d, fromState: State(z: input.z)).z
                guard let s = recurse(.init(iPart: input.iPart + 1, z: z)) else { continue }
                return [d] + s
            }
            return nil
        }
    }

    func makeMinSolver(_ parts: [Monad]) -> Solver {
        memoizeRecursive { input, recurse in
            guard input.iPart < 14 else {
                return input.z == 0 ? [] : nil
            }

            let part = parts[input.iPart]
            let sig = part.signature

            for d in 1 ... 9 {
                if sig.pop, d != (input.z % 26) + sig.p {
                    continue
                }

                let z = part.runOn(d, fromState: State(z: input.z)).z
                guard let s = recurse(.init(iPart: input.iPart + 1, z: z)) else { continue }
                return [d] + s
            }
            return nil
        }
    }

    typealias DigitZ = (d: Int, z: Int)
    static let digits = (1 ... 9).reversed().asArray

    static let noBiggerThan = 89_560_000_099_999
    // static let zs = (0 ... 26 * 26).asArray

    struct Monad: CustomStringConvertible {
        let instructions: [Instruction]

        func runOn(_ model: Int, fromState state: State = State()) -> State {
            let modelDigits = "\(model)".map { $0.wholeNumberValue! }
            var model = modelDigits[...]
            let input: () -> Int = {
                defer { model = model.dropFirst() }
                return model.first!
            }

            return runOn(input, fromState: state)
        }

        func runOn(_ input: () -> Int, fromState state: State) -> State {
            instructions.reduce(into: state) { state, op in
                state.execute(op, input: input)
            }
        }

        var signature: (pop: Bool, p: Int, zAdd: Int) {
            (pop: isPop, p: zDifference, zAdd: zAdd)
        }

        var zDifference: Int {
            let zDiffs = instructions
                .compactMap { i -> Int? in
                    guard case let .add(.x, .integer(diff)) = i else { return nil }
                    return diff
                }
            assert(zDiffs.count == 1)
            return zDiffs[0]
        }

        var zAdd: Int {
            let addInstruction = instructions.suffix(3).first!
            guard case let .add(.y, .integer(add)) = addInstruction else { fatalError() }
            return add
        }

        var isPop: Bool {
            let divs = instructions
                .compactMap { i -> Int? in
                    guard case let .div(.z, .integer(p)) = i else { return nil }
                    return p
                }
            assert(divs.count == 1)
            return divs[0] == 26 ? true : false
        }

        var parts: [Monad] {
            instructions.chunked { _, rhs in
                if case .inp = rhs { return false } else { return true }
            }.map { Monad(instructions: Array($0)) }
        }

        static func + (lhs: Monad, rhs: Monad) -> Monad {
            Monad(instructions: lhs.instructions + rhs.instructions)
        }

        var description: String {
            instructions.map(\.description).joined(separator: "\n")
        }
    }

    struct State: CustomStringConvertible {
        var w = 0
        var x = 0
        var y = 0
        var z = 0

        mutating func execute(_ i: Instruction, input: () -> Int) {
            switch i {
            case let .inp(a):
                self[a] = input()
            case let .add(a, b):
                self[a] = self[a] + self[b]
            case let .mul(a, b):
                self[a] = self[a] * self[b]
            case let .div(a, b):
                assert(self[a] >= 0)
                assert(self[b] > 0)
                self[a] = self[a] / self[b]
            case let .mod(a, b):
                self[a] = self[a] % self[b]
            case let .eql(a, b):
                self[a] = self[a] == self[b] ? 1 : 0
            }
        }

        subscript(o: Operand) -> Int {
            get {
                switch o {
                case .w: return w
                case .x: return x
                case .y: return y
                case .z: return z
                case let .integer(i): return i
                }
            }
            set {
                switch o {
                case .w: w = newValue
                case .x: x = newValue
                case .y: y = newValue
                case .z: z = newValue
                case .integer: fatalError()
                }
            }
        }

        var isValid: Bool { z == 0 }

        var description: String {
            "\(w), \(x), \(y), \(z)"
        }
    }

    enum Operand: Equatable, CustomStringConvertible {
        case w, x, y, z
        case integer(Int)

        var description: String {
            switch self {
            case .w: return "w"
            case .x: return "x"
            case .y: return "y"
            case .z: return "z"
            case let .integer(i): return "\(i)"
            }
        }
    }

    enum Instruction: Equatable, CustomStringConvertible {
        case inp(Operand)
        case add(a: Operand, b: Operand)
        case mul(a: Operand, b: Operand)
        case div(a: Operand, b: Operand)
        case mod(a: Operand, b: Operand)
        case eql(a: Operand, b: Operand)

        var description: String {
            switch self {
            case let .inp(r): return "inp \(r)"
            case let .add(a, b): return "add \(a) \(b)"
            case let .mul(a, b): return "mul \(a) \(b)"
            case let .div(a, b): return "div \(a) \(b)"
            case let .mod(a, b): return "mod \(a) \(b)"
            case let .eql(a, b): return "eql \(a) \(b)"
            }
        }
    }
}

extension Day24Tests {
    static let input = resourceURL(filename: "Day24Input.txt")!.readContents()!

    static var example: String {
        """
        inp w
        add z w
        mod z 2
        div w 2
        add y w
        mod y 2
        div w 2
        add x w
        mod x 2
        div w 2
        mod w 2
        """
    }

    // MARK: - parser

    static let operandParser: AnyParser<Substring.UTF8View, Day24Tests.Operand> =
        OneOf {
            "w".utf8.map { Operand.w }
            "x".utf8.map { Operand.x }
            "y".utf8.map { Operand.y }
            "z".utf8.map { Operand.z }
            Int.parser().map { Operand.integer($0) }
        }.eraseToAnyParser()

    static let inpParser =
        Parse { Instruction.inp($0) } with: {
            "inp ".utf8
            operandParser
        }.eraseToAnyParser()
    static let addParser =
        Parse { Instruction.add(a: $0, b: $1) } with: {
            "add ".utf8
            operandParser
            " ".utf8
            operandParser
        }.eraseToAnyParser()
    static let mulParser =
        Parse { Instruction.mul(a: $0, b: $1) } with: {
            "mul ".utf8
            operandParser
            " ".utf8
            operandParser
        }.eraseToAnyParser()
    static let divParser =
        Parse { Instruction.div(a: $0, b: $1) } with: {
            "div ".utf8
            operandParser
            " ".utf8
            operandParser
        }.eraseToAnyParser()
    static let modParser =
        Parse { Instruction.mod(a: $0, b: $1) } with: {
            "mod ".utf8
            operandParser
            " ".utf8
            operandParser
        }.eraseToAnyParser()

    static let eqlParser =
        Parse { Instruction.eql(a: $0, b: $1) } with: {
            "eql ".utf8
            operandParser
            " ".utf8
            operandParser
        }.eraseToAnyParser()

    static let instructionParser: AnyParser<Substring.UTF8View, Day24Tests.Instruction> =
        OneOf { inpParser; addParser; mulParser; divParser; modParser; eqlParser }.eraseToAnyParser()

    static let monadParser = Parse { Monad(instructions: $0) } with: {
        Many(atLeast: 1) { instructionParser } separator: { "\n".utf8 }
        Skip { Optionally { "\n".utf8 } }
    }

    func testParseExample() {
        let monad = try! Self.monadParser.parse(Self.example)
        XCTAssertEqual(monad.instructions.count, 11)
    }

    func testParseInput() {
        let monad = try! Self.monadParser.parse(Self.input)
        XCTAssertEqual(monad.instructions.count, 252)
        XCTAssertEqual(monad.instructions.last, Instruction.add(a: .z, b: .y))
    }
}
