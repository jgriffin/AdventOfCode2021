//
//
// Created by John Griffin on 12/2/21
//

@testable import AdventOfCode2021
import Foundation
import Parsing
import XCTest

final class Day02Tests: XCTestCase {
    let input = resourceURL(filename: "Day02Input.txt")!.readContents()!

    let example = """
    forward 5
    down 5
    forward 8
    up 3
    down 8
    forward 2
    """

    enum Command {
        case forward(Int), down(Int), up(Int)
    }

    struct Postion: Equatable {
        var horizontal: Int = 0
        var depth: Int = 0
        var aim: Int = 0

        func apply(_ command: Command) -> Postion {
            switch command {
            case let .forward(forward):
                return .init(horizontal: horizontal + forward, depth: depth)
            case let .down(down):
                return .init(horizontal: horizontal, depth: depth + down)
            case let .up(up):
                return .init(horizontal: horizontal, depth: depth - up)
            }
        }

        func apply2(_ command: Command) -> Postion {
            switch command {
            case let .forward(forward):
                return .init(
                    horizontal: horizontal + forward,
                    depth: depth + aim * forward,
                    aim: aim
                )
            case let .down(down):
                return .init(
                    horizontal: horizontal,
                    depth: depth,
                    aim: aim + down
                )
            case let .up(up):
                return .init(
                    horizontal: horizontal,
                    depth: depth,
                    aim: aim - up
                )
            }
        }

        func apply(_ commands: [Command]) -> Postion {
            commands.reduce(self) { partialResult, command in
                partialResult.apply(command)
            }
        }

        func apply2(_ commands: [Command]) -> Postion {
            commands.reduce(self) { partialResult, command in
                partialResult.apply2(command)
            }
        }
    }

    static let commandParser = OneOfMany(
        Skip("forward").skip(" ").take(Int.parser()).map(Command.forward),
        Skip("down").skip(" ").take(Int.parser()).map(Command.down),
        Skip("up").skip(" ").take(Int.parser()).map(Command.up)
    )

    static let commandsParser = Many(commandParser, separator: "\n")

    func testParseExample() {
        let commands = Self.commandsParser.parse(example)
        XCTAssertEqual(commands?.count, 6)
    }

    func testParseInput() {
        let commands = Self.commandsParser.parse(input)
        XCTAssertEqual(commands?.count, 1000)
    }

    func testSolveExample() {
        let commands = Self.commandsParser.parse(example)!
        let result = Postion().apply(commands)
        XCTAssertEqual(result, Postion(horizontal: 15, depth: 10))
        XCTAssertEqual(result.horizontal * result.depth, 150)
    }

    func testSolveInput() {
        let commands = Self.commandsParser.parse(input)!
        let result = Postion().apply(commands)
        XCTAssertEqual(result, Postion(horizontal: 2003, depth: 872))
        XCTAssertEqual(result.horizontal * result.depth, 1_746_616)
    }

    func testSolve2Example() {
        let commands = Self.commandsParser.parse(example)!
        let result = Postion().apply2(commands)
        XCTAssertEqual(result, Postion(horizontal: 15, depth: 60, aim: 10))
        XCTAssertEqual(result.horizontal * result.depth, 900)
    }

    func testSolve2Input() {
        let commands = Self.commandsParser.parse(input)!
        let result = Postion().apply2(commands)
        XCTAssertEqual(result, Postion(horizontal: 2003, depth: 869_681, aim: 872))
        XCTAssertEqual(result.horizontal * result.depth, 1_741_971_043)
    }
}
