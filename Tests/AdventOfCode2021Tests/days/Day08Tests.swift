//
//
// Created by John Griffin on 12/8/21
//

@testable import AdventOfCode2021
import Parsing
import XCTest

final class Day08Tests: XCTestCase {
    let input = resourceURL(filename: "Day08Input.txt")!.readContents()!

    let example = """
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    """

    typealias WireSet = Set<Character>
    typealias Entry = (wires: [WireSet], displays: [WireSet])
    typealias EntryDigits = (wires: [Int], displays: [Int])
    typealias WireSetDigitMap = [WireSet: Int]

    static let wireSetParser = Prefix(1..., while: { $0.isLetter }).map { WireSet($0) }
    static let wireSetsParser = Many { wireSetParser } separator: { " " }
    static let entryParser = Parse { Entry($0, $1) } with: {
        wireSetsParser
        " | "
        wireSetsParser
    }

    static let inputParser = Parse {
        Many { entryParser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() {
        let entries = try! Self.inputParser.parse(example)
        XCTAssertEqual(entries.count, 10)
        XCTAssertEqual(entries.last?.displays.last, WireSet("bagce"))
    }

    func testParseInput() {
        let entries = try! Self.inputParser.parse(input)
        XCTAssertEqual(entries.count, 200)
        XCTAssertEqual(entries.last?.displays.last, WireSet("cbgda"))
    }

    let easyDigits = Set([1, 4, 7, 8])

    func testSimpleWireSetMapExample() {
        let entries = try! Self.inputParser.parse(example)

        let entriesDisplayDigits = entriesDisplayDigitsFrom(entries)

        let easiesCount = entriesDisplayDigits.flatMap { $0 }
            .filter(easyDigits.contains)
            .count

        XCTAssertEqual(easiesCount, 26)
    }

    func testSimpleWireSetMapInput() {
        let entries = try! Self.inputParser.parse(input)

        let entriesDisplayDigits = entriesDisplayDigitsFrom(entries)

        let easiesCount = entriesDisplayDigits.flatMap { $0 }
            .filter(easyDigits.contains)
            .count

        XCTAssertEqual(easiesCount, 330)
    }

    func testAllWireSetMapExample() {
        let entries = try! Self.inputParser.parse(example)

        let entriesDisplayDigits = entriesDisplayDigitsFrom(entries)
        let entriesDisplayNumbers = entriesDisplayDigits.map {
            $0.reduce(0) { result, next in
                result * 10 + next
            }
        }

        let entriesDisplayNumbersSum = entriesDisplayNumbers.reduce(0,+)
        XCTAssertEqual(entriesDisplayNumbersSum, 61229)
    }

    func testAllWireSetMapInput() {
        let entries = try! Self.inputParser.parse(input)

        let entriesDisplayDigits = entriesDisplayDigitsFrom(entries)
        let entriesDisplayNumbers = entriesDisplayDigits.map {
            $0.reduce(0) { result, next in
                result * 10 + next
            }
        }

        let entriesDisplayNumbersSum = entriesDisplayNumbers.reduce(0,+)
        XCTAssertEqual(entriesDisplayNumbersSum, 1_010_472)
    }

    func testWireSetDigitMap() {
        let test: [WireSet] = [
            Set("eb"), Set("fgbeadc"), Set("becdgf"), Set("facdeg"), Set("cgbe"),
            Set("gecfd"), Set("afdebg"), Set("cdebf"), Set("dacfb"), Set("bde"),
        ]

        let digitMap = wireSetDigitMap(test)
        let result = test.map { digitMap[$0]! }
        XCTAssertEqual(result, [1, 8, 9, 6, 4, 5, 0, 3, 2, 7])
    }
}

extension Day08Tests {
    func entriesDisplayDigitsFrom(_ entries: [Entry]) -> [[Int]] {
        entriesDigitsFrom(entries).map(\.displays)
    }

    func entriesDigitsFrom(_ entries: [Entry]) -> [EntryDigits] {
        let entriesMaps = entries.map { wireSetDigitMap($0.wires) }
        XCTAssertTrue(entriesMaps.allSatisfy { $0.count == 10 })

        let entriesDigits = zip(entries, entriesMaps).map(entryDigitsFrom)
        return entriesDigits
    }

    func wireSetDigitMap(_ wireSets: [WireSet]) -> WireSetDigitMap {
        var easyMap = wireSets
            .reduce(into: WireSetDigitMap()) { result, wireSet in
                switch wireSet.count {
                case 2: result[wireSet] = 1
                case 3: result[wireSet] = 7
                case 4: result[wireSet] = 4
                case 5: break // 2,3,5
                case 6: break // 0,6,9
                case 7: result[wireSet] = 8
                default: fatalError()
                }
            }

        // augment with sixes
        let oneSet = easyMap.first { $0.value == 1 }!.key
        let fourSet = easyMap.first { $0.value == 4 }!.key

        for wireSet in wireSets where wireSet.count == 6 {
            // 0,6,9
            if wireSet.isSuperset(of: fourSet) {
                easyMap[wireSet] = 9
            } else if wireSet.isSuperset(of: oneSet) {
                easyMap[wireSet] = 0
            } else {
                easyMap[wireSet] = 6
            }
        }

        let easyDigitWires = easyMap.reduce(into: [Int: WireSet]()) { result, wireSetDigit in
            result[wireSetDigit.value] = wireSetDigit.key
        }

        let fives = wireSets.filter { $0.count == 5 }

        func known(_ digit: Int) -> WireSet { easyDigitWires[digit]! }

        func only(_ characters: Set<Character>) -> Character {
            assert(characters.count == 1)
            return characters.first!
        }

        let c = only(known(0).subtracting(known(6)))
        let e = only(known(8).subtracting(known(9)))

        let fivesMap = fives.reduce(into: WireSetDigitMap()) { result, wireSet in
            // 2,3,5,9
            if !wireSet.contains(c) {
                result[wireSet] = 5
            } else if wireSet.contains(e) {
                result[wireSet] = 2
            } else {
                result[wireSet] = 3
            }
        }

        return easyMap.merging(fivesMap) { _, _ in fatalError() }
    }

    func entryDigitsFrom(entry: Entry, map: WireSetDigitMap) -> EntryDigits {
        (entry.wires.map { map[$0]! },
         entry.displays.map { map[$0]! })
    }
}
