//
//
// Created by John Griffin on 12/6/21
//

@testable import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day06Tests: XCTestCase {
    let input = resourceURL(filename: "Day06Input.txt")!.readContents()!

    let example = """
    3,4,3,1,2
    """

    static let timerParser = Many(Int.parser(), separator: ",")

    func testParseExample() {
        let timers = Self.timerParser.parse(example)
        XCTAssertEqual(timers, [3, 4, 3, 1, 2])
    }

    func testParseInput() {
        let timers = Self.timerParser.parse(input)!
        XCTAssertEqual(timers.count, 300)
        XCTAssertEqual(timers.last, 3)
    }

    func testAdvanceTimers() {
        var timers = [3]
        timers = advanceTimersOnce(timers)
        XCTAssertEqual(timers, [2])
        timers = advanceTimersOnce(timers)
        XCTAssertEqual(timers, [1])
        timers = advanceTimersOnce(timers)
        XCTAssertEqual(timers, [0])
        timers = advanceTimersOnce(timers)
        XCTAssertEqual(timers, [6, 8])
        timers = advanceTimersOnce(timers)
        XCTAssertEqual(timers, [5, 7])

        let advanced5 = advanceTimers([3], times: 5)
        XCTAssertEqual(advanced5, [5, 7])
    }

    func testAdvance80Example() {
        let timers = Self.timerParser.parse(example)!

        let advanced18 = advanceTimers(timers, times: 18)
        XCTAssertEqual(advanced18.count, 26)

        let advanced80 = advanceTimers(timers, times: 80)
        XCTAssertEqual(advanced80.count, 5934)
    }

    func testAdvance80Input() {
        let timers = Self.timerParser.parse(input)!

        let advanced80 = advanceTimers(timers, times: 80)
        XCTAssertEqual(advanced80.count, 380_612)
    }

    func testAdvanceTimerCounts() {
        let timers = [3]
        var timerCounts = timerCountsFrom(timers)
        XCTAssertEqual(fishCountFrom(timerCounts), 1)

        timerCounts = advanceTimerCountsOnce(timerCounts)
        XCTAssertEqual(timerCounts, [2: 1])
        XCTAssertEqual(fishCountFrom(timerCounts), 1)

        timerCounts = advanceTimerCountsOnce(timerCounts)
        XCTAssertEqual(timerCounts, [1: 1])
        XCTAssertEqual(fishCountFrom(timerCounts), 1)

        timerCounts = advanceTimerCountsOnce(timerCounts)
        XCTAssertEqual(timerCounts, [0: 1])
        XCTAssertEqual(fishCountFrom(timerCounts), 1)

        timerCounts = advanceTimerCountsOnce(timerCounts)
        XCTAssertEqual(timerCounts, [6: 1, 8: 1])
        XCTAssertEqual(fishCountFrom(timerCounts), 2)

        timerCounts = advanceTimerCountsOnce(timerCounts)
        XCTAssertEqual(timerCounts, [5: 1, 7: 1])

        let advanced5 = advanceTimerCounts(
            timerCountsFrom(timers),
            times: 5
        )
        XCTAssertEqual(advanced5, [5: 1, 7: 1])
        XCTAssertEqual(fishCountFrom(advanced5), 2)
    }

    func testAdvanceTimerCounts80Example() {
        let timers = Self.timerParser.parse(example)!
        let timerCounts = timerCountsFrom(timers)
        XCTAssertEqual(fishCountFrom(timerCounts), 5)

        let advanced18 = advanceTimerCounts(timerCounts, times: 18)
        XCTAssertEqual(fishCountFrom(advanced18), 26)

        let advanced80 = advanceTimerCounts(timerCounts, times: 80)
        XCTAssertEqual(fishCountFrom(advanced80), 5934)
    }

    func testAdvanceTimerCounts256Example() {
        let timers = Self.timerParser.parse(example)!
        let timerCounts = timerCountsFrom(timers)

        let advanced256 = advanceTimerCounts(timerCounts, times: 256)
        XCTAssertEqual(fishCountFrom(advanced256), 26_984_457_539)
    }

    func testAdvanceTimerCounts256Input() {
        let timers = Self.timerParser.parse(input)!
        let timerCounts = timerCountsFrom(timers)

        let advanced256 = advanceTimerCounts(timerCounts, times: 256)
        XCTAssertEqual(fishCountFrom(advanced256), 1_710_166_656_900)
    }
}

extension Day06Tests {
    typealias TimerCounts = [Int: Int]

    func timerCountsFrom(_ timers: [Int]) -> TimerCounts {
        Dictionary(grouping: timers, by: { $0 })
            .reduce(into: TimerCounts()) { result, next in
                result[next.key] = next.value.count
            }
    }

    func fishCountFrom(_ timerCounts: TimerCounts) -> Int {
        timerCounts.values.reduce(0, +)
    }

    func advanceTimerCounts(_ timerCounts: TimerCounts, times: Int) -> TimerCounts {
        var timerCounts = timerCounts
        for _ in 0 ..< times {
            timerCounts = advanceTimerCountsOnce(timerCounts)
        }
        return timerCounts
    }

    func advanceTimerCountsOnce(_ timerCounts: TimerCounts) -> TimerCounts {
        var nextTimerCounts = timerCounts
            .reduce(into: TimerCounts()) { result, next in
                if next.key == 0 {
                    result[6, default: 0] += next.value
                } else {
                    result[next.key - 1, default: 0] += next.value
                }
            }

        if let births = timerCounts[0] {
            nextTimerCounts[8] = births
        }
        return nextTimerCounts
    }

    func advanceTimers(_ timers: [Int], times: Int) -> [Int] {
        var timers = timers
        for _ in 0 ..< times {
            timers = advanceTimersOnce(timers)
        }
        return timers
    }

    func advanceTimersOnce(_ timers: [Int]) -> [Int] {
        let births = timers.filter { $0 == 0 }.count
        return timers.map { time in
            time == 0 ? 6 : time - 1
        } + Array(repeating: 8, count: births)
    }
}
