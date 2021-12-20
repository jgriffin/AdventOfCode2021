//
//
// Created by John Griffin on 12/19/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day18Tests: XCTestCase {
    let input = resourceURL(filename: "Day18Input.txt")!.readContents()!

    var magnitudeExample: String {
        """
        [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
        [[[5,[2,8]],4],[5,[[9,9],0]]]
        [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
        [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
        [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
        [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
        [[[[5,4],[7,7]],8],[[8,3],8]]
        [[9,3],[[9,9],[6,[4,9]]]]
        [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
        [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
        """
    }

    func testLargestSumExample() {
        let numbers = Self.numbersParser.parse(magnitudeExample)!
        let sumMagnitudes = numbers.permutations(ofCount: 2)
            .map { ($0, magnitude: ($0[0] + $0[1]).magnitude) }
        let largest = sumMagnitudes.max { $0.magnitude < $1.magnitude }

        XCTAssertEqual(largest?.magnitude, 3993)
    }

    func testLargestSumInput() {
        let numbers = Self.numbersParser.parse(input)!
        let sumMagnitudes = numbers.permutations(ofCount: 2)
            .map { ($0, magnitude: ($0[0] + $0[1]).magnitude) }
        let largest = sumMagnitudes.max { $0.magnitude < $1.magnitude }

        XCTAssertEqual(largest?.magnitude, 4659)
    }

    func testMagnitudeExample() {
        let numbers = Self.numbersParser.parse(magnitudeExample)!
        let sum = numbers.reduce(.empty, +)
        let magnitude = sum.magnitude

        XCTAssertEqual(magnitude, 4140)
    }

    func testMagnitudeInput() {
        let numbers = Self.numbersParser.parse(input)!
        let sum = numbers.reduce(.empty, +)
        let magnitude = sum.magnitude

        XCTAssertEqual(magnitude, 4235)
    }

    func testMagnitudeExamples() {
        let tests: [(test: Snailfish, check: Int)] = [
            ("[[1,2],[[3,4],5]]", 143),
            ("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384),
            ("[[[[1,1],[2,2]],[3,3]],[4,4]]", 445),
            ("[[[[3,0],[5,3]],[4,4]],[5,5]]", 791),
            ("[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137),
            ("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488),
        ].map { (Snailfish($0), $1) }

        tests.forEach { test in
            let result = test.test.magnitude
            XCTAssertEqual(result, test.check)
        }
    }

    // MARK: - add

    func testSimpleAddExample() {
        let lhs = Snailfish("[[[[4,3],4],4],[7,[[8,4],9]]]")
        let rhs = Snailfish("[1,1]")
        let check = Snailfish("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
        let result = lhs + rhs
        XCTAssertEqual(result, check)
    }

    func testAddExamples() {
        let test = """
        [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
        [7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
        [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
        [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
        [7,[5,[[3,8],[1,4]]]]
        [[2,[2,2]],[8,[8,1]]]
        [2,9]
        [1,[[[9,3],9],[[9,0],[0,7]]]]
        [[[5,[7,4]],7],1]
        [[[[4,2],2],6],[8,7]]
        """
        let check = Snailfish("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")

        let numbers = Self.numbersParser.parse(test)!
        XCTAssertEqual(numbers.count, 10)

        let sum = numbers.reduce(.empty, +)
        XCTAssertEqual(sum, check)
    }

    // MARK: - explode and split

    func testExplodeExamples() {
        let tests: [(test: Snailfish, check: Snailfish)] = [
            ("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"),
            ("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"),
            ("[[6,[5,[4,[3,2]]]],1]", "[[6,[5,[7,0]]],3]"),
            ("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"),
            ("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"),
        ].map { (Snailfish($0), Snailfish($1)) }

        tests.forEach { test in
            let result = Snailfish(Self.reduceOnce(test.test.tokens))
            XCTAssertEqual(result, test.check)
        }
    }

    func testSplitExamples() {
        let tests: [(test: Snailfish, check: Snailfish)] = [
            ("10", "[5,5]"),
            ("11", "[5,6]"),
            ("12", "[6,6]"),
        ].map { (Snailfish($0), Snailfish($1)) }

        tests.forEach { test in
            let result = Snailfish(Self.split(test.test.tokens, atNumber: 0))
            XCTAssertEqual(result, test.check)
        }
    }

    // MARK: - parser

    static let numbersParser = Many(SnailfishParser.snailfishParser, separator: "\n".utf8)
        .skip(Optional.parser(of: "\n".utf8))
        .skip(End())

    func testParseExample() {
        let lines = Self.numbersParser.parse(magnitudeExample)!
        XCTAssertEqual(lines.count, 10)
    }

    func testParseInput() {
        let input = Self.numbersParser.parse(input)!
        XCTAssertEqual(input.count, 100)
    }
}

extension Day18Tests {
    enum Token: Equatable, CustomStringConvertible {
        case open, close, number(Int), comma

        var asNumber: Int? {
            switch self {
            case let .number(n): return n
            default: return nil
            }
        }

        var description: String {
            switch self {
            case .open: return "["
            case .close: return "]"
            case let .number(n): return "\(n)"
            case .comma: return ","
            }
        }
    }

    struct Snailfish: Equatable, CustomStringConvertible {
        let tokens: [Token]

        init(_ tokens: [Token]) {
            self.tokens = tokens
        }

        init(_ string: String) {
            self = SnailfishParser.snailfishParser.parse(string)!
        }

        static let empty = Snailfish([])

        var description: String { tokens.map(\.description).joined() }

        var reduced: Snailfish {
            var result = tokens
            while true {
                let reduction = Day18Tests.reduceOnce(result)
                if reduction == result {
                    break
                }
                result = reduction
            }
            return Snailfish(result)
        }

        static func + (_ lhs: Snailfish, _ rhs: Snailfish) -> Snailfish {
            guard lhs != .empty else { return rhs }

            let combined = [.open] + lhs.tokens + [.comma] + rhs.tokens + [.close]
            return Snailfish(combined).reduced
        }

        var magnitude: Int {
            if case let .number(n) = tokens.first {
                return n
            }
            let (left, right) = pair
            return left.magnitude * 3 + right.magnitude * 2
        }

        var pair: (left: Snailfish, right: Snailfish) {
            guard case .open = tokens.first else { fatalError() }
            let comma = Day18Tests.firstCommaAtDepth1(tokens)!

            return (
                left: Snailfish(tokens[1 ..< comma].asArray),
                right: Snailfish(tokens[(comma + 1) ..< tokens.count - 1].asArray)
            )
        }
    }

    enum SnailfishParser {
        static let openParser = "[".utf8.map { Token.open }
        static let closeParser = "]".utf8.map { Token.close }
        static let commaParser = ",".utf8.map { Token.comma }
        static let numberParser = Int.parser().utf8.map { Token.number($0) }
        static let tokenParser = openParser.orElse(closeParser).orElse(numberParser).orElse(commaParser)
        static let snailfishParser = Many(tokenParser, atLeast: 1).map { Snailfish($0) }
    }

    // MARK: - reduce

    static func reduceOnce(_ tokens: [Token]) -> [Token] {
        if let indexOfOpen = firstOpenAtDepth4(tokens) {
            return expand(tokens, atPairOpen: indexOfOpen)
        }

        if let indexOf10 = first10OrGreater(tokens) {
            return split(tokens, atNumber: indexOf10)
        }

        return tokens
    }

    static func expand(_ tokens: [Token], atPairOpen i: Int) -> [Token] {
        guard case .open = tokens[i] else { fatalError() }

        let firstNumber = tokens[i + 1].asNumber!
        assert(tokens[i + 2] == .comma)
        let secondNumber = tokens[i + 3].asNumber!
        let pairClose = i + 4
        assert(tokens[pairClose] == .close)

        var result = tokens

        if let leftNumber = numberToLeft(i, tokens) {
            result[leftNumber.i] = .number(leftNumber.n + firstNumber)
        }
        if let rightNumber = numberToRight(pairClose, tokens) {
            result[rightNumber.i] = .number(rightNumber.n + secondNumber)
        }

        result.replaceSubrange(i ... pairClose, with: [.number(0)])
        return result
    }

    static func split(_ tokens: [Token], atNumber i: Int) -> [Token] {
        guard let number = tokens[i].asNumber else { fatalError() }

        var result = tokens
        result.replaceSubrange(i ... i, with: [
            .open, .number(number / 2), .comma, .number((number + 1) / 2), .close,
        ])
        return result
    }

    // MARK: - helpers

    static func firstOpenAtDepth4(_ tokens: [Token]) -> Int? {
        var depth = 0
        for (i, t) in tokens.enumerated() {
            switch t {
            case .open where depth >= 4:
                return i
            case .open:
                depth += 1
            case .close:
                depth -= 1
            case .comma: continue
            case .number: continue
            }
        }
        return nil
    }

    static func firstCommaAtDepth1(_ tokens: [Token]) -> Int? {
        var depth = 0
        for (i, t) in tokens.enumerated() {
            switch t {
            case .open:
                depth += 1
            case .close:
                depth -= 1
            case .comma where depth == 1: return i
            case .comma: continue
            case .number: continue
            }
        }
        return nil
    }

    static func first10OrGreater(_ tokens: [Token]) -> Int? {
        for (i, t) in tokens.enumerated() {
            switch t {
            case .open, .close, .comma: continue
            case let .number(n) where n >= 10:
                return i
            case .number: continue
            }
        }
        return nil
    }

    static func numberToLeft(_ ofIndex: Int, _ tokens: [Token]) -> (i: Int, n: Int)? {
        var l = ofIndex - 1
        while l > 0 {
            if let n = tokens[l].asNumber {
                return (i: l, n: n)
            }
            l -= 1
        }
        return nil
    }

    static func numberToRight(_ ofIndex: Int, _ tokens: [Token]) -> (i: Int, n: Int)? {
        var r = ofIndex + 1
        while r < tokens.count {
            if let n = tokens[r].asNumber {
                return (i: r, n: n)
            }
            r += 1
        }
        return nil
    }
}
