//
//
// Created by John Griffin on 12/13/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day14Tests: XCTestCase {
    let input = resourceURL(filename: "Day14Input.txt")!.readContents()!

    var example: String {
        """
        NNCB

        CH -> B
        HH -> N
        CB -> H
        NH -> C
        HB -> C
        HC -> B
        HN -> C
        NN -> C
        BH -> H
        NC -> B
        NB -> B
        BN -> B
        BB -> N
        BC -> B
        CC -> N
        CN -> C
        """
    }

    func testExpander40Example() async {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(example)
        let insMap = insertionMapFrom(insertions)
        let expander = Expander(insertionMap: insMap)

        let counts = await expander.characterCountsExpanding(template, toDepth: 40)
        XCTAssertEqual(counts.values.reduce(0, +), 3_298_534_883_329)

        let result = mostLessLeastCommonCount(counts)
        XCTAssertEqual(result, 2_188_189_693_529)
    }

    func testExpander40Input() async {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(input)
        let insMap = insertionMapFrom(insertions)
        let expander = Expander(insertionMap: insMap)

        let counts = await expander.characterCountsExpanding(template, toDepth: 40)
        XCTAssertEqual(counts.values.reduce(0, +), 20_890_720_927_745)

        let result = mostLessLeastCommonCount(counts)
        XCTAssertEqual(result, 2_158_894_777_814)
    }

    func testExpander10Example() async {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(example)
        let insMap = insertionMapFrom(insertions)
        let expander = Expander(insertionMap: insMap)

        let counts = await expander.characterCountsExpanding(template, toDepth: 10)
        XCTAssertEqual(counts.values.reduce(0, +), 3073)

        let result = mostLessLeastCommonCount(counts)
        XCTAssertEqual(result, 1588)
    }

    func testExpander10Input() async {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(input)
        let insMap = insertionMapFrom(insertions)
        let expander = Expander(insertionMap: insMap)

        let counts = await expander.characterCountsExpanding(template, toDepth: 10)

        XCTAssertEqual(counts.values.reduce(0, +), 19457)

        let result = mostLessLeastCommonCount(counts)
        XCTAssertEqual(result, 2068)
    }

    func testApplyPreExpandedInsertions10Example() {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(example)
        let insMap = insertionMapFrom(insertions)

        let expanded10InsMap = expandInsMap(insMap, times: 10)
        let expanded = applyInsertions(expanded10InsMap, to: template)
        XCTAssertEqual(expanded.count, 3073)

        let result = mostLessLeastCommonCount(expanded)
        XCTAssertEqual(result, 1588)
    }

    func testApplyInsertions10Example() {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(example)
        let insMap = insertionMapFrom(insertions)

        let step1 = applyInsertions(insMap, to: template)
        XCTAssertEqual(step1, "NCNBCHB")

        let expanded = (0 ..< 10).reduce(String(template)) { str, _ in
            applyInsertions(insMap, to: str)
        }
        XCTAssertEqual(expanded.count, 3073)

        let result = mostLessLeastCommonCount(expanded)
        XCTAssertEqual(result, 1588)
    }

    func testApplyInsertions10Input() {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(input)
        let insMap = insertionMapFrom(insertions)

        let step1 = applyInsertions(insMap, to: template)
        XCTAssertEqual(step1, "KOFVFVNNFVNONSBPCBNNOHBPCBNVPCFBVOKFCSP")

        let step10 = (0 ..< 10).reduce(String(template)) { str, _ in
            applyInsertions(insMap, to: str)
        }
        XCTAssertEqual(step10.count, 19457)

        let result = mostLessLeastCommonCount(step10)
        XCTAssertEqual(result, 2068)
    }

    // MARK: - parsing

    func testParseExample() {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(example)
        XCTAssertEqual(template, "NNCB")
        XCTAssertEqual(insertions.count, 16)
        XCTAssertEqual(insertions.last?.ins, "C")
    }

    func testParseInput() {
        let (template, insertions) = try! Self.templatesAndInsertions.parse(input)
        XCTAssertEqual(template, "KFFNFNNBCNOBCNPFVKCP")
        XCTAssertEqual(insertions.count, 100)
        XCTAssertEqual(insertions.last?.ins, "H")
    }

    struct Insertion: Equatable {
        let pair: Substring
        let ins: Substring
    }

    static let templateParser = Prefix(while: { $0.isLetter })
    static let insertionParser =
        Parse { Insertion(pair: $0, ins: $1) } with: {
            Prefix(while: { $0.isLetter })
            " -> "
            First().map { String($0)[...] }
        }

    static let insertionsParser = Many { insertionParser } separator: { "\n" }
    static let templatesAndInsertions = Parse {
        templateParser.map { String($0) }
        "\n\n"
        insertionsParser
        Skip { Optionally { "\n" } }
    }
}

extension Day14Tests {
    struct Expansion: Hashable {
        let str: Substring
        let toDepth: Int

        init(_ str: Substring, toDepth: Int) {
            self.str = str
            self.toDepth = toDepth
        }
    }

    typealias CharacterCounts = [Character: Int]

    class Expander {
        let insertionMap: InsertionMap
        var expansionCache = [Expansion: CharacterCounts]()

        init(insertionMap: InsertionMap) {
            self.insertionMap = insertionMap
        }

        func characterCountsExpanding(_ str: String, toDepth: Int) async -> CharacterCounts {
            var counts = await characterCounts(Expansion(str[...], toDepth: toDepth))

            // and we add the last character back
            counts[str.last!, default: 0] += 1
            return counts
        }

        func characterCounts(_ e: Expansion) async -> CharacterCounts {
            assert(!e.str.isEmpty)

            guard e.str.count != 1 else {
                return [e.str.first!: 1]
            }

            if let cached = expansionCache[e] {
                return cached
            }

            let counts: CharacterCounts
            defer { expansionCache[e] = counts }

            guard e.toDepth > 0 else {
                counts = e.str.dropLast().reduce(into: CharacterCounts()) { result, ch in
                    result[ch, default: 0] += 1
                }
                return counts
            }

            counts = await expand(e)
                .map { await self.characterCounts($0) }
                .reduce(into: CharacterCounts()) { result, counts in
                    result.merge(counts, uniquingKeysWith: +)
                }
            return counts
        }

        func expand(_ e: Expansion) -> AsyncStream<Expansion> {
            AsyncStream { continuation in
                guard e.toDepth > 0 else {
                    continuation.yield(e)
                    return
                }
                guard e.str.count > 1 else {
                    continuation.yield(
                        Expansion(e.str, toDepth: e.toDepth - 1)
                    )
                    return
                }

                e.str.windows(ofCount: 2).lazy.forEach { pair in
                    guard let i = self.insertionMap[pair] else {
                        continuation.yield(Expansion(pair, toDepth: 0))
                        return
                    }
                    continuation.yield(Expansion(pair.prefix(1) + i, toDepth: e.toDepth - 1))
                    continuation.yield(Expansion(i + pair.dropFirst(), toDepth: e.toDepth - 1))
                }

                continuation.finish()
            }
        }
    }

    // MARK: - InsertionMap

    typealias InsertionMap = [Substring: Substring]

    func insertionMapFrom(_ insertions: [Insertion]) -> [Substring: Substring] {
        insertions.reduce(into: [Substring: Substring]()) { result, ins in
            result[ins.pair] = String(ins.ins)[...]
        }
    }

    func expandInsMap(_ insMap: InsertionMap, times: Int) -> InsertionMap {
        insMap.reduce(into: InsertionMap()) { result, keyValue in
            result[keyValue.key] = (0 ..< times)
                .reduce(String(keyValue.key)) { str, _ in
                    applyInsertions(insMap, to: str)
                }.dropFirst().dropLast()
        }
    }

    func applyInsertions(_ insertionMap: InsertionMap, to input: String) -> String {
        input.windows(ofCount: 2).reduce(into: "") { output, pair in
            output.append(pair.first!)
            if let i = insertionMap[pair] {
                output.append(contentsOf: i)
            }
        } + [input.last!]
    }

    func mostLessLeastCommonCount(_ str: String) -> Int {
        let counts = Dictionary(grouping: str) { ch in ch }
            .values.map(\.count)
            .sorted()
        return counts.last! - counts.first!
    }

    func mostLessLeastCommonCount(_ counts: CharacterCounts) -> Int {
        let sorted = counts.values.sorted()
        return sorted.last! - sorted.first!
    }
}
