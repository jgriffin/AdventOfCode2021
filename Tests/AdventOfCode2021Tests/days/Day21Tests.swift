//
// Created by John Griffin on 12/21/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day21Tests: XCTestCase {
    func testPlayToWinnerDirac() {
        let players = Players(initialP1Space: 2, p2Space: 1)
        let wins = Game.playToWinnerDirac(players)
        XCTAssertEqual(wins, Wins(27_464_148_626_406, 22_909_380_722_959))

        let mostWins = max(wins.p1, wins.p2)
        XCTAssertEqual(mostWins, 27_464_148_626_406)
    }

    func testPlayToWinnerDiracExample() {
        let players = Players(initialP1Space: 4, p2Space: 8)
        let wins = Game.playToWinnerDirac(players)
        XCTAssertEqual(wins, Wins(444_356_092_776_315, 341_960_390_180_808))
    }

    func testPlayToWinner() {
        // input
        // Player 1 starting position: 2
        // Player 2 starting position: 1
        let die = DeterministicDie(sides: 100)
        var game = Game(Players(initialP1Space: 2, p2Space: 1))

        game.playToWinner(die)

        XCTAssertEqual(game.score, Score(730, 1005))
        XCTAssertEqual(die.rollsCount, 1092)
        XCTAssertEqual(game.result(die), 797_160)
    }

    func testPlayToWinnerExample() {
        let die = DeterministicDie(sides: 100)
        var game = Game(Players(initialP1Space: 4, p2Space: 8))

        game.playToWinner(die)

        XCTAssertEqual(game.score, Score(1000, 745))
        XCTAssertEqual(die.rollsCount, 993)
        XCTAssertEqual(game.result(die), 739_785)
    }

    func testTakeTurn() {
        let die = DeterministicDie(sides: 100)
        var game = Game(Players(initialP1Space: 4, p2Space: 8))

        game.takeTurnP1(die)
        game.takeTurnP2(die)
        XCTAssertEqual(game.score, Score(10, 3))

        game.takeTurnP1(die)
        game.takeTurnP2(die)
        XCTAssertEqual(game.score, Score(14, 9))

        game.takeTurnP1(die)
        game.takeTurnP2(die)
        XCTAssertEqual(game.score, Score(20, 16))
    }

    func testDiracDice() {
        XCTAssertEqual(
            DiracDice.sumCounts,
            [
                .init(sum: 3, count: 1),
                .init(sum: 4, count: 3),
                .init(sum: 5, count: 6),
                .init(sum: 6, count: 7),
                .init(sum: 7, count: 6),
                .init(sum: 8, count: 3),
                .init(sum: 9, count: 1),
            ]
        )
    }

    func testRollDie100() {
        let die = DeterministicDie(sides: 100)
        let rolls = (0 ..< 101).map { _ in die.roll() }
        XCTAssertEqual(rolls.suffix(2).first, 100)
        XCTAssertEqual(rolls.last, 1)
        XCTAssertEqual(die.rollsCount, 101)
    }

    func testRollDie() {
        let die = DeterministicDie(sides: 3)
        let rolls = (0 ..< 6).map { _ in die.roll() }
        XCTAssertEqual(rolls, [1, 2, 3, 1, 2, 3])
        XCTAssertEqual(die.rollsCount, 6)
    }
}

extension Day21Tests {
    struct Game {
        var players: Players
        var score: Score { Score(players.p1.score, players.p2.score) }

        init(_ players: Players) {
            self.players = players
        }

        static let playToWinnerDirac: (Players) -> Wins =
            memoizeRecursive { (players: Players, recurse) in
                guard players.p1.score < 21 else { return Score(1, 0) }
                guard players.p2.score < 21 else { return Score(0, 1) }

                return DiracDice.sumCounts
                    .map { sumCount in
                        recurse(Players(players.p2, players.p1.move(sumCount.sum))) * sumCount.count
                    }
                    .reduce(.zero,+)
                    .swapped
            }

        mutating func playToWinner(_ die: DeterministicDie) {
            players = Self.playToWinner(players, die: die)
        }

        static func playToWinner(_ p: Players, die: DeterministicDie) -> Players {
            guard p.p1.score < 1000, p.p2.score < 1000 else { return p }
            return playToWinner(Players(p.p2, p.p1.move(die.roll3())),
                                die: die).swapped
        }

        mutating func takeTurnP1(_ die: DeterministicDie) {
            players = Players(players.p1.move(die.roll3()), players.p2)
        }

        mutating func takeTurnP2(_ die: DeterministicDie) {
            players = Players(players.p1, players.p2.move(die.roll3()))
        }

        func result(_ die: DeterministicDie) -> Int {
            assert((players.p1.score >= 1000) != (players.p2.score >= 1000))
            return min(players.p1.score, players.p2.score) * die.rollsCount
        }
    }

    struct Players: Hashable {
        let p1: Player
        let p2: Player

        init(_ p1: Player, _ p2: Player) {
            self.p1 = p1
            self.p2 = p2
        }

        init(initialP1Space p1Space: Int, p2Space: Int) {
            self.init(Player(pos: p1Space - 1, score: 0),
                      Player(pos: p2Space - 1, score: 0))
        }

        var swapped: Players { Players(p2, p1) }
    }

    struct Player: Hashable {
        let pos: Int
        let score: Int

        init(pos: Int, score: Int) {
            self.pos = pos
            self.score = score
        }

        static let spaces = 10

        func move(_ spaces: Int) -> Player {
            let nextPos = (pos + spaces) % Self.spaces
            return Player(
                pos: nextPos,
                score: score + Self.spaceFromPos(nextPos)
            )
        }

        static func spaceFromPos(_ pos: Int) -> Int {
            (pos + 1 == Self.spaces) ? Self.spaces : pos + 1
        }
    }

    struct Score: Equatable {
        let p1, p2: Int
        init(_ p1: Int, _ p2: Int) {
            self.p1 = p1
            self.p2 = p2
        }

        var swapped: Score { Score(p2, p1) }
        static let zero = Score(0, 0)

        static func + (lhs: Score, rhs: Score) -> Score { Score(lhs.p1 + rhs.p1, lhs.p2 + rhs.p2) }
        static func * (lhs: Score, count: Int) -> Score { Score(lhs.p1 * count, lhs.p2 * count) }
    }

    typealias Wins = Score

    class DeterministicDie {
        init(sides: Int) {
            self.sides = sides
            state = -1
        }

        let sides: Int
        var state: Int
        var rollsCount: Int = 0

        func roll() -> Int {
            state = (state + 1) % sides
            rollsCount += 1
            return state + 1
        }

        func roll3() -> Int {
            roll() + roll() + roll()
        }
    }

    enum DiracDice {
        static let sumCounts = countSums()

        struct SumCount: Equatable { let sum, count: Int }

        static func countSums() -> [SumCount] {
            typealias Tripple = (Int, Int, Int)
            let combos = product(1 ... 3, product(1 ... 3, 1 ... 3)).map { Tripple($0, $1.0, $1.1) }
            XCTAssertEqual(combos.count, 27)

            let bySum = [Int: [Tripple]](grouping: combos,
                                         by: { c in c.0 + c.1 + c.2 })
            let sumCounts = bySum
                .map { k, values in SumCount(sum: k, count: values.count) }
                .sorted { lhs, rhs in lhs.sum < rhs.sum }
            return sumCounts
        }
    }
}
