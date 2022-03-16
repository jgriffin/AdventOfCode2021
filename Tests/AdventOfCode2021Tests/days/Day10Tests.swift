//
//
// Created by John Griffin on 12/10/21
//

@testable import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day10Tests: XCTestCase {
    let input = resourceURL(filename: "Day10Input.txt")!.readContents()!

    let example = """
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
    """

    static let openSet = Set("([{<")
    static let closeSet = Set(">}])")
    static let validSet = openSet.union(closeSet)

    static let parseLine = Prefix(1..., while: validSet.contains)
    static let parseLines = Parse {
        Many { parseLine } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    // MARK: parse tests

    func testParseExample() {
        let lines = try! Self.parseLines.parse(example)
        XCTAssertEqual(lines.count, 10)
        XCTAssertEqual(lines.last?.last, "]")
    }

    func testParseInput() {
        let lines = try! Self.parseLines.parse(input)
        XCTAssertEqual(lines.count, 110)
        XCTAssertEqual(lines.last?.last, ")")
    }

    // MARK: invalid tests

    func testInvalidScoreExample() {
        let lines = try! Self.parseLines.parse(example)
        let invalidLines = lines.compactMap(invalidLine)
        XCTAssertEqual(invalidLines.count, 5)

        let score = invalidLines.map(\.ch).map(valueForInvalid).reduce(0,+)
        XCTAssertEqual(score, 26397)
    }

    func testInvalidScoreInput() {
        let lines = try! Self.parseLines.parse(input)
        let invalidLines = lines.compactMap(invalidLine)
        XCTAssertEqual(invalidLines.count, 55)

        let score = invalidLines.map(\.ch).map(valueForInvalid).reduce(0,+)
        XCTAssertEqual(score, 392_097)
    }

    // MARK: completion tests

    func testIncompleteLineExample() {
        let lines = try! Self.parseLines.parse(example)
        let incompleteLines = lines.compactMap(incompleteLine)
        XCTAssertEqual(incompleteLines.count, 5)
    }

    func testAutocompleScoreExample() {
        let lines = try! Self.parseLines.parse(example)
        let incompleteLines = lines.compactMap(incompleteLine)

        let completions = incompleteLines.map { autoCompleteLine($0.s) }.map(\.completion)
        XCTAssertEqual(completions.count, 5)

        let completionScores = completions.map(completionScore)
        XCTAssertEqual(completionScores, [288_957, 5566, 1_480_781, 995_444, 294])

        let sortedCompletionScores = completions.map(completionScore).sorted()
        let middle = sortedCompletionScores[sortedCompletionScores.count / 2]
        XCTAssertEqual(middle, 288_957)
    }

    func testAutocompleScoreInput() {
        let lines = try! Self.parseLines.parse(input)
        let incompleteLines = lines.compactMap(incompleteLine)

        let completions = incompleteLines.map { autoCompleteLine($0.s) }.map(\.completion)
        XCTAssertEqual(completions.count, 55)

        let sortedCompletionScores = completions.map(completionScore).sorted()
        let middle = sortedCompletionScores[sortedCompletionScores.count / 2]
        XCTAssertEqual(middle, 4_263_222_782)
    }

    // MARK: - parse tests

    func testValidParseChunks() throws {
        let tests = [
            "",
            "()",
            "(())",
            "([])",
        ]

        try tests.forEach { test in
            let result = try parseChunks(test[...])
            XCTAssertEqual(result, "")
        }
    }

    func testInvalidParseChunks() throws {
        let tests: [(s: String, ch: Character)] = [
            ("(]", "]"),
            ("(<)", ")"),
            ("([]()]", "]"),
        ]

        try tests.forEach { test in
            do {
                _ = try parseChunks(test.s[...])
                XCTFail("didn't throw")
            } catch ParseError.invalid(test.ch) {
                // expected
            }
        }
    }

    func testIncompleteParseChunks() throws {
        let tests = [
            "(",
            "(<",
            "(<>",
            "(()",
        ]

        try tests.forEach { test in
            do {
                _ = try parseChunks(test[...])
                XCTFail("didn't throw")
            } catch ParseError.incomplete {
                // expected
            }
        }
    }
}

extension Day10Tests {
    // MARK: autocomplet

    typealias LineCompletion = (s: Substring, completion: String)

    func autoCompleteLine(_ line: Substring) -> LineCompletion {
        var completion = ""

        while let incomplete = incompleteLine(line + completion) {
            completion.append(incomplete.ch)
        }

        return (line, completion)
    }

    func completionScore(_ completion: String) -> Int {
        completion.map(valueForCompletion).reduce(0) { result, next in
            result * 5 + next
        }
    }

    func valueForCompletion(_ o: Character) -> Int {
        switch o {
        case")": return 1
        case "]": return 2
        case "}": return 3
        case ">": return 4
        default: fatalError()
        }
    }

    // MARK: incomplete

    typealias IncompleteLine = (s: Substring, ch: Character)

    func incompleteLine(_ line: Substring) -> IncompleteLine? {
        let (line, result) = parseLine(line)

        switch result {
        case .success: return nil
        case .failure(.invalid): return nil
        case let .failure(.incomplete(ch)):
            return (line, ch)
        }
    }

    // MARK: invalid

    typealias InvalidLine = (s: Substring, ch: Character)

    func invalidLine(_ line: Substring) -> InvalidLine? {
        let (line, result) = parseLine(line)

        switch result {
        case .success: return nil
        case .failure(.incomplete): return nil
        case let .failure(.invalid(ch)):
            return (line, ch)
        }
    }

    func valueForInvalid(_ o: Character) -> Int {
        switch o {
        case")": return 3
        case "]": return 57
        case "}": return 1197
        case ">": return 25137
        default: fatalError()
        }
    }

    // MARK: parse

    enum ParseError: Error {
        case incomplete(Character)
        case invalid(Character)
    }

    typealias ParseResult = Result<Void, ParseError>

    func parseLine(_ line: Substring) -> (Substring, ParseResult) {
        do {
            _ = try parseChunks(line)
            return (line, .success(()))
        } catch let e as ParseError {
            return (line, .failure(e))
        } catch {
            fatalError()
        }
    }

    func parseChunks(_ s: Substring) throws -> Substring {
//        print("parseChunks: \(s)")

        guard let open = s.first, Self.openSet.contains(open) else {
            return s
        }
        let expectingClose = closeForOpen(open)

        var rest = s.dropFirst()

        if rest.first.flatMap(Self.openSet.contains) ?? false {
            rest = try parseChunks(rest)
        }

        guard let close = rest.first else {
            throw ParseError.incomplete(expectingClose)
        }

        guard close == expectingClose else {
            throw ParseError.invalid(close)
        }

        return try parseChunks(rest.dropFirst())
    }

    func closeForOpen(_ o: Character) -> Character {
        switch o {
        case "(": return ")"
        case "[": return "]"
        case "{": return "}"
        case "<": return ">"
        default: fatalError()
        }
    }
}
