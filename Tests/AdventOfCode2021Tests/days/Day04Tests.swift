//
//
// Created by John Griffin on 12/4/21
//

@testable import AdventOfCode2021
import Foundation
import Parsing
import XCTest

final class Day04Tests: XCTestCase {
    let input = resourceURL(filename: "Day04Input.txt")!.readContents()!

    let example = """
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
     8  2 23  4 24
    21  9 14 16  7
     6 10  3 18  5
     1 12 20 15 19

     3 15  0  2 22
     9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
     2  0 12  3  7
    """

    static let numbersParser = Many { Int.parser() } separator: { "," }
    static let boardNumber = Parse { Skip { Optionally { " " }}; Int.parser() }
    static let rowParser = Many(atLeast: 1) { boardNumber } separator: { " " }
    static let boardParser = Many { rowParser } separator: { "\n" }.map(Board.init)
    static let boardsParser = Many { boardParser } separator: { "\n\n" }
    static let inputParser = Parse {
        numbers, boards in GameState(boards: boards, numbers: numbers)
    } with: {
        numbersParser
        "\n\n"
        boardsParser
        Skip { Optionally { "\n" }}
    }

    struct Board {
        let rows: [[Int]]

        var cols: [[Int]] {
            rows.first!.indices.map { c in
                rows.map { $0[c] }
            }
        }

        func isWinner(_ drawnNumbers: Array<Int>.SubSequence) -> Bool {
            let drawnNumbers = Set(drawnNumbers)

            if rows.contains(where: { row in
                row.allSatisfy(drawnNumbers.contains)
            }) {
                return true
            }

            if cols.contains(where: { col in
                col.allSatisfy(drawnNumbers.contains)
            }) {
                return true
            }

            return false
        }

        func score(drawnNumbers: Array<Int>.SubSequence) -> Int {
            let unmarked = unmarkedNumbers(drawnNumbers)
            return unmarked.reduce(0,+) * drawnNumbers.last!
        }

        func unmarkedNumbers(_ drawnNumbers: Array<Int>.SubSequence) -> Set<Int> {
            let drawnNumbers = Set(drawnNumbers)
            return Set(rows.flatMap { $0 }.filter { !drawnNumbers.contains($0) })
        }
    }

    struct GameState {
        let boards: [Board]
        var numbers: [Int]

        var drawnCount = 0
        var drawnNumbers: Array<Int>.SubSequence { numbers[0 ..< drawnCount] }
        var lastNumberDrawn: Int? { drawnNumbers.last }

        func winners() -> [Board] {
            boards.filter { $0.isWinner(drawnNumbers) }
        }

        func nonWinners() -> [Board] {
            boards.filter { !$0.isWinner(drawnNumbers) }
        }

        mutating func drawUntilWinner() -> Board? {
            var winner: Board?
            while winner == nil {
                drawnCount += 1
                winner = winners().first
            }

            return winner
        }

        mutating func drawUntilLastWinner() -> Board? {
            // draw until 1 non-winner
            var remainingNonWinners = boards
            while remainingNonWinners.count > 1 {
                drawnCount += 1
                remainingNonWinners = nonWinners()
            }

            guard let lastWinner = remainingNonWinners.first else { return nil }

            // advance until last winner wins
            while !lastWinner.isWinner(drawnNumbers) {
                drawnCount += 1
            }
            return lastWinner
        }
    }

    func testParseExample() {
        let game = try! Self.inputParser.parse(example)
        XCTAssertEqual(game.numbers.last, 1)

        print(game.boards)
        XCTAssertEqual(game.boards.count, 3)
        XCTAssertEqual(game.boards.last?.rows.last, [2, 0, 12, 3, 7])
    }

    func testParseInput() {
        let game = try! Self.inputParser.parse(input)
        XCTAssertEqual(game.numbers.last, 11)
        XCTAssertEqual(game.boards.count, 100)
        XCTAssertEqual(game.boards.last?.rows.last, [17, 49, 91, 30, 33])
    }

    func testWinnerExample() {
        var game = try! Self.inputParser.parse(example)

        let winner = game.drawUntilWinner()
        let score = winner!.score(drawnNumbers: game.drawnNumbers)
        XCTAssertEqual(score, 4512)
    }

    func testWinnerInput() {
        var game = try! Self.inputParser.parse(input)

        let winner = game.drawUntilWinner()
        let score = winner!.score(drawnNumbers: game.drawnNumbers)
        XCTAssertEqual(score, 39902)
    }

    func testLastWinnerExample() {
        var game = try! Self.inputParser.parse(example)

        let winner = game.drawUntilLastWinner()
        let score = winner!.score(drawnNumbers: game.drawnNumbers)
        XCTAssertEqual(score, 1924)
    }

    func testLastWinnerInput() {
        var game = try! Self.inputParser.parse(input)

        let winner = game.drawUntilLastWinner()
        let score = winner!.score(drawnNumbers: game.drawnNumbers)
        XCTAssertEqual(score, 26936)
    }
}
