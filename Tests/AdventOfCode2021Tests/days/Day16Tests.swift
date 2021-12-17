//
//
// Created by John Griffin on 12/16/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day16Tests: XCTestCase {
    let input = resourceURL(filename: "Day16Input.txt")!.readContents()!

    let literalExample: String = "D2FE28"
    let opLengthExample: String = "38006F45291200"
    let opCountExample: String = "EE00D40C823060"

    // MARK: - value

    func testValueExamples() {
        let tests: [(hex: String, value: Int)] = [
            ("C200B40A82", 3),
            ("04005AC33890", 54),
            ("880086C3E88112", 7),
            ("CE00C43D881120", 9),
            ("D8005AC2A8F0", 1),
            ("F600BC2D8F", 0),
            ("9C005AC2F8F0", 0),
            ("9C0141080250320F1802104A08", 1),
        ]

        tests.forEach { test in
            let result = Self.packetHexParser.parse(test.hex)
//            print(result!.description)
            XCTAssertEqual(result?.value, test.value, test.hex)
        }
    }

    func testValueInput() {
        let result = Self.packetHexParser.parse(input)
        XCTAssertEqual(result?.value, 831_996_589_851)
//        print(result!.description)
    }

    // MARK: - version sum

    func testVersionSumExamples() {
        let tests: [(hex: String, verSum: Int)] = [
            ("8A004A801A8002F478", 16),
            ("620080001611562C8802118E34", 12),
            ("C0015000016115A2E0802F182340", 23),
            ("A0016C880162017C3686B18A3D4780", 31),
        ]

        tests.forEach { test in
            let package = Self.packetHexParser.parse(test.hex)
            XCTAssertEqual(package?.versionSum, test.verSum)
        }
    }

    func testVersionSumInput() {
        let package = Self.packetHexParser.parse(input)
        XCTAssertEqual(package?.versionSum, 971)
    }

    // MARK: - parser tests

    func testParseLiteralExample() {
        let bin = Self.hex2BinParser.parse(literalExample)!
        XCTAssertEqual(bin, Substring("110100101111111000101000"))
        let literalPacket = PP.literalParser.parse(bin)!
        XCTAssertEqual(literalPacket, .literal(ver: 6, value: 2021))

        let literalPacket2 = PP.literalParser.parse("11010001010")!
        XCTAssertEqual(literalPacket2, .literal(ver: 6, value: 10))

        let literalPacket3 = PP.literalParser.parse("0101001000100100")!
        XCTAssertEqual(literalPacket3, .literal(ver: 2, value: 20))
    }

    func testParseOpLengthExample() {
        let bin = Self.hex2BinParser.parse(opLengthExample)!
        let packet = PP.operationParser.parse(bin)!

        guard case let .op(ver, op, subpackets) = packet else { fatalError() }

        XCTAssertEqual(ver, 1)
        XCTAssertEqual(op, .lessThan)
        XCTAssertEqual(subpackets.count, 2)
        XCTAssertEqual(subpackets[0], .literal(ver: 6, value: 10))
        XCTAssertEqual(subpackets[1], .literal(ver: 2, value: 20))
    }

    func testParseOpCountExample() {
        let bin = Self.hex2BinParser.parse(opCountExample)!
        let packet = PP.operationParser.parse(bin)!

        guard case let .op(ver, op, subpackets) = packet else { fatalError() }

        XCTAssertEqual(ver, 7)
        XCTAssertEqual(op, .maximum)
        XCTAssertEqual(subpackets.count, 3)
        XCTAssertEqual(subpackets[0], .literal(ver: 2, value: 1))
        XCTAssertEqual(subpackets[1], .literal(ver: 4, value: 2))
        XCTAssertEqual(subpackets[2], .literal(ver: 1, value: 3))
    }

    static let hex2BinParser = Prefix<Substring>(while: { $0.isHexDigit })
        .map { Substring($0.flatMap { hex2Bin[$0]! }) }
    static let packetHexParser = hex2BinParser.pipe(PP.packetParser)
}

extension Day16Tests {
    indirect enum Packet: Equatable, CustomStringConvertible {
        case literal(ver: Int, value: Int)
        case op(ver: Int, op: Operation, packets: [Packet])

        var description: String {
            switch self {
            case let .literal(_, value):
                return "\(value)"
            case let .op(_, op, packets):
                switch op {
                case .sum:
                    let args = packets.map(\.description).joined(separator: " + ")
                    return "(\(args))"
                case .product:
                    let args = packets.map(\.description).joined(separator: " * ")
                    return "\(args)"
                case .minimum:
                    let args = packets.map(\.description).joined(separator: ", ")
                    return "min(\(args))"
                case .maximum:
                    let args = packets.map(\.description).joined(separator: ", ")
                    return "max(\(args))"
                case .greaterThan:
                    return "(\(packets[0]) > \(packets[1]))"
                case .lessThan:
                    return "(\(packets[0]) < \(packets[1]))"
                case .equal:
                    return "\(packets[0]) = \(packets[1])"
                }
            }
        }

        var version: Int {
            switch self {
            case let .literal(ver, _), let .op(ver, _, _):
                return ver
            }
        }

        var versionSum: Int {
            switch self {
            case let .literal(ver, _):
                return ver
            case let .op(ver, _, packets):
                return packets.map(\.versionSum).reduce(ver, +)
            }
        }

        var value: Int {
            switch self {
            case let .literal(_, value):
                return value
            case let .op(_, op, packets):
                switch op {
                case .sum:
                    return packets.map(\.value).reduce(0,+)
                case .product:
                    return packets.map(\.value).reduce(1,*)
                case .minimum:
                    return packets.map(\.value).reduce(.max, min)
                case .maximum:
                    return packets.map(\.value).reduce(.min, max)
                case .greaterThan:
                    return packets[0].value > packets[1].value ? 1 : 0
                case .lessThan:
                    return packets[0].value < packets[1].value ? 1 : 0
                case .equal:
                    return packets[0].value == packets[1].value ? 1 : 0
                }
            }
        }
    }

    enum Operation: Int {
        case sum = 0
        case product = 1
        case minimum = 2
        case maximum = 3
        case greaterThan = 5
        case lessThan = 6
        case equal = 7
    }

    enum SubLengthType: Equatable {
        case bits(Int)
        case count(Int)
    }

    typealias PP = PacketParser

    enum PacketParser {
        static let packetParser = literalParser.orElse(operationParser)

        // MARK: literal parser

        static let literalParser = versionParser.skip("100").take(literalValueParser)
            .map { Packet.literal(ver: $0, value: $1) }

        static let literalValueParser = LiteralValueParser()

        struct LiteralValueParser: Parser {
            func parse(_ input: inout Substring) -> Int? {
                let originalInput = input

                func restoreInputAndNil() -> Int? {
                    input = originalInput
                    return nil
                }

//                // strip leading zeros
//                guard let _ = Prefix(while: { $0 == "0" }).parse(&input) else {
//                    return restoreInputAndNil()
//                }

                // take chunks starting with 1
                guard let oneChunks = Many(Skip("1").take(Prefix(4))).parse(&input) else {
                    return restoreInputAndNil()
                }

                // last chunk starts with 0
                guard let zeroChunk = Skip("0").take(Prefix(4)).parse(&input) else {
                    return restoreInputAndNil()
                }

                return intFromBin(oneChunks.joined() + zeroChunk)
            }

            static let literalGroupsParser = Skip(extraZeros).take(Many(literalGroupParser)).skip(extraZeros)
            static let literalGroupParser = Skip(First()).take(Prefix<Substring>(4))
        }

        // MARK: operation parser

        static let operationParser = versionParser.take(typeIdParser).take(operationSubparsersParser)
            .map { Packet.op(ver: $0, op: Operation(rawValue: $1)!, packets: $2) }
        static let typeIdParser = intFromBinParser(3)
        static let operationSubparsersParser = OpSubParsersParser()

        struct OpSubParsersParser: Parser {
            func parse(_ input: inout Substring) -> [Packet]? {
                let originalInput = input

                func restoreInputAndNil() -> [Packet]? {
                    input = originalInput
                    return nil
                }

                guard let lengthType = Self.opLengthTypeParser.parse(&input) else {
                    return restoreInputAndNil()
                }

                switch lengthType {
                case let .bits(bitCount):
                    guard let result = Prefix(bitCount)
                        .pipe(Many(PacketParser.packetParser))
                        .parse(&input)
                    else {
                        return restoreInputAndNil()
                    }
                    return result

                case let .count(packetCount):
                    guard let result = Many(PacketParser.packetParser,
                                            atLeast: packetCount, atMost: packetCount)
                        .parse(&input)
                    else {
                        return restoreInputAndNil()
                    }
                    return result
                }
            }

            static let opLengthTypeParser = OneOfMany(
                Skip("0").take(intFromBinParser(15)).map { SubLengthType.bits($0) },
                Skip("1").take(intFromBinParser(11)).map { SubLengthType.count($0) }
            ).eraseToAnyParser()
        }

        // MARK: utils

        static func intFromBin<S: StringProtocol>(_ s: S) -> Int {
            Int(s, radix: 2)!
        }

        static func intFromBinParser(_ length: Int) -> AnyParser<Substring, Int> {
            Prefix<Substring>(length).map(intFromBin).eraseToAnyParser()
        }

        static let versionParser = intFromBinParser(3)

        static let extraZeros = Many("0", atMost: 3)
    }
}

extension Day16Tests {
    static let hex2Bin: [Character: [Character]] = [
        ("0", "0000"),
        ("1", "0001"),
        ("2", "0010"),
        ("3", "0011"),
        ("4", "0100"),
        ("5", "0101"),
        ("6", "0110"),
        ("7", "0111"),
        ("8", "1000"),
        ("9", "1001"),
        ("A", "1010"),
        ("B", "1011"),
        ("C", "1100"),
        ("D", "1101"),
        ("E", "1110"),
        ("F", "1111"),
    ].reduce(into: [Character: [Character]]()) { result, hAndBin in
        result[hAndBin.0] = Array(hAndBin.1)
    }
}
