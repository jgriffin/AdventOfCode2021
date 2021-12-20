//
//  File.swift
//
//
//  Created by Griff on 12/20/21.
//

import Accelerate
import AdventOfCode2021
import Algorithms
import Parsing
import simd
import XCTest

final class Day19Tests: XCTestCase {
    let input = resourceURL(filename: "Day19Input.txt")!.readContents()!

    func testFindAllBeaconsExample() {
        let scanners = Self.scannersParser.parse(example)!

        let (beacons, placedScanners) = findAllBeacons(scanners)

        XCTAssertEqual(beacons.count, 79)
        XCTAssertEqual(placedScanners.count, scanners.count)

        let positions = placedScanners.map(\.p.position)
        let manhattanVectors = positions.combinations(ofCount: 2)
            .map { $0[0] &- $0[1] }
        let manhattanDistances = manhattanVectors
            .map { abs($0.x) + abs($0.y) + abs($0.z) }
        let longestDistance = manhattanDistances.max()!
        XCTAssertEqual(longestDistance, 3621)
    }

    func testFindAllBeaconsInput() {
        let scanners = Self.scannersParser.parse(input)!

        let (beacons, placedScanners) = findAllBeacons(scanners)

        XCTAssertEqual(beacons.count, 383)
        XCTAssertEqual(placedScanners.count, scanners.count)

        let positions = placedScanners.map(\.p.position)
        let manhattanVectors = positions.combinations(ofCount: 2)
            .map { $0[0] &- $0[1] }
        let manhattanDistances = manhattanVectors
            .map { abs($0.x) + abs($0.y) + abs($0.z) }
        let longestDistance = manhattanDistances.max()!
        XCTAssertEqual(longestDistance, 9854)
    }

    func testPlacementOfScanner1() {
        let scanners = Self.scannersParser.parse(example)!
        let beacons = scanners[0].measurements.asSet

        guard let placement = placementOfScanner(scanners[1], givenBeacons: beacons) else {
            fatalError()
        }

        let positionCheck = Position(68, -1246, -43)
        let rotationCheck = Rotation(rows: [
            simd_float3(-1.0, 0.0, 0.0),
            simd_float3(0.0, 1.0, 0.0),
            simd_float3(0.0, 0.0, -1.0),
        ])

        XCTAssertEqual(placement.position, positionCheck)
        XCTAssertEqual(placement.rotation, rotationCheck)
    }

    func testPositionOFScanner0() {
        let scanner0 = Self.scannersParser.parse(example)!.first!
        let beacons = scanner0.measurements.asSet

        guard let positionAndRotation = placementOfScanner(scanner0, givenBeacons: beacons) else {
            fatalError()
        }
        XCTAssertEqual(positionAndRotation.position, Position.zero)
        XCTAssertEqual(positionAndRotation.rotation, matrix_identity_float3x3)
    }

    func testAllRotations() {
        let pt = Position(1, 2, 3)
        let rotations = Self.allRotations.map { Self.rotateIndex3(pt, $0) }
        XCTAssertEqual(rotations.count, 24)
    }

    // MARK: - parser

    func testParseExample() {
        let scanners = Self.scannersParser.parse(example)!
        XCTAssertEqual(scanners.count, 5)
    }

    func testParseInput() {
        let scanners = Self.scannersParser.parse(input)!
        XCTAssertEqual(scanners.count, 33)
        XCTAssertEqual(scanners.last?.measurements.last, Position(-632, 720, 398))
    }

    static let headingParser = "--- scanner ".utf8.take(Int.parser()).skip(" ---".utf8).skip("\n".utf8)
        .map { "scanner \($0)" }
    static let xyxParser = Many(Int.parser(), atLeast: 3, atMost: 3, separator: ",".utf8)
        .map { Position($0[0], $0[1], $0[2]) }
    static let scannerParser = headingParser.take(Many(xyxParser, separator: "\n".utf8))
        .map { Scanner(name: $0, measurements: $1) }
    static let scannersParser = Many(scannerParser, separator: "\n\n".utf8)
        .skip(Many("\n".utf8, atLeast: 0))
        .skip(End())
}

extension Day19Tests {
    typealias Position = SIMD3<Int>
    typealias Beacons = Set<Position>
    typealias PlacedScanner = (s: Scanner, p: ScannerPlacement)

    func findAllBeacons(_ scanners: [Scanner]) -> (Beacons, [PlacedScanner]) {
        var beacons = Beacons()
        var placedScanners: [PlacedScanner] = []
        var unplacedScanners = scanners.asSet

        func placeScanner(_ s: Scanner, at p: ScannerPlacement) {
            beacons.formUnion(s.measurementsAfterPlacement(p))
            placedScanners.append(PlacedScanner(s, p))
            unplacedScanners.remove(s)
        }

        // first scanner sets the origin
        placeScanner(
            scanners[0],
            at: ScannerPlacement(position: .zero,
                                 count: scanners[0].measurements.count,
                                 rotation: matrix_identity_float3x3)
        )

        while !unplacedScanners.isEmpty {
            for s in unplacedScanners {
                guard let placement = placementOfScanner(s, givenBeacons: beacons) else { continue }
                placeScanner(s, at: placement)
                break
            }
        }

        return (beacons, placedScanners)
    }

    struct Scanner: Hashable, CustomStringConvertible {
        let name: String
        let measurements: [Position]

        var description: String {
            "\(name)" + measurements.map(\.description).joined(separator: " ")
        }

        func measurementsRotated(by r: Rotation) -> [Position] {
            measurements.map { m in Day19Tests.rotateIndex3(m, r) }
        }

        func measurementsAfterPlacement(_ p: ScannerPlacement) -> [Position] {
            measurementsRotated(by: p.rotation)
                .map { $0 &+ p.position }
        }
    }

    struct ScannerPlacement: Equatable, CustomStringConvertible {
        let position: Position
        let count: Int
        let rotation: Rotation

        var description: String {
            "p:\(stringI(position)), c:\(count) r:\(stringM(rotation))"
        }
    }

    func placementOfScanner(
        _ s: Scanner,
        givenBeacons beacons: Beacons
    ) -> ScannerPlacement? {
        for r in Self.allRotations {
            guard let (position, count) = positionOfScanner(s, withRotation: r, givenBeacons: beacons) else {
                continue
            }

            return ScannerPlacement(position: position, count: count, rotation: r)
        }
        return nil
    }

    func positionOfScanner(
        _ s: Scanner,
        withRotation rotation: Rotation,
        givenBeacons beacons: Beacons
    ) -> (position: Position, count: Int)? {
        let rotatedMeasurements = s.measurementsRotated(by: rotation)

        let projectedRotationsField = rotatedMeasurements.flatMap { m in
            beacons.map { b in b &- m }
        }

        let projectedPositionsAndCounts = Dictionary(grouping: projectedRotationsField, by: { $0 })
            .map { k, values in (position: k, count: values.count) }
        let sortedPositions = projectedPositionsAndCounts
            .sorted(by: { $0.count < $1.count })

        let mostCommonPosition = sortedPositions.last!
        guard mostCommonPosition.count >= 12 else {
            return nil
        }

        return mostCommonPosition
    }

    var example: String {
        """
        --- scanner 0 ---
        404,-588,-901
        528,-643,409
        -838,591,734
        390,-675,-793
        -537,-823,-458
        -485,-357,347
        -345,-311,381
        -661,-816,-575
        -876,649,763
        -618,-824,-621
        553,345,-567
        474,580,667
        -447,-329,318
        -584,868,-557
        544,-627,-890
        564,392,-477
        455,729,728
        -892,524,684
        -689,845,-530
        423,-701,434
        7,-33,-71
        630,319,-379
        443,580,662
        -789,900,-551
        459,-707,401

        --- scanner 1 ---
        686,422,578
        605,423,415
        515,917,-361
        -336,658,858
        95,138,22
        -476,619,847
        -340,-569,-846
        567,-361,727
        -460,603,-452
        669,-402,600
        729,430,532
        -500,-761,534
        -322,571,750
        -466,-666,-811
        -429,-592,574
        -355,545,-477
        703,-491,-529
        -328,-685,520
        413,935,-424
        -391,539,-444
        586,-435,557
        -364,-763,-893
        807,-499,-711
        755,-354,-619
        553,889,-390

        --- scanner 2 ---
        649,640,665
        682,-795,504
        -784,533,-524
        -644,584,-595
        -588,-843,648
        -30,6,44
        -674,560,763
        500,723,-460
        609,671,-379
        -555,-800,653
        -675,-892,-343
        697,-426,-610
        578,704,681
        493,664,-388
        -671,-858,530
        -667,343,800
        571,-461,-707
        -138,-166,112
        -889,563,-600
        646,-828,498
        640,759,510
        -630,509,768
        -681,-892,-333
        673,-379,-804
        -742,-814,-386
        577,-820,562

        --- scanner 3 ---
        -589,542,597
        605,-692,669
        -500,565,-823
        -660,373,557
        -458,-679,-417
        -488,449,543
        -626,468,-788
        338,-750,-386
        528,-832,-391
        562,-778,733
        -938,-730,414
        543,643,-506
        -524,371,-870
        407,773,750
        -104,29,83
        378,-903,-323
        -778,-728,485
        426,699,580
        -438,-605,-362
        -469,-447,-387
        509,732,623
        647,635,-688
        -868,-804,481
        614,-800,639
        595,780,-596

        --- scanner 4 ---
        727,592,562
        -293,-554,779
        441,611,-461
        -714,465,-776
        -743,427,-804
        -660,-479,-426
        832,-632,460
        927,-485,-438
        408,393,-506
        466,436,-512
        110,16,151
        -258,-428,682
        -393,719,612
        -211,-452,876
        808,-476,-593
        -575,615,604
        -485,667,467
        -680,325,-822
        -627,-443,-432
        872,-547,-609
        833,512,582
        807,604,487
        839,-516,451
        891,-625,532
        -652,-548,-490
        30,-46,-14
        """
    }
}

extension Day19Tests {
    static let sins: [Float] = [0, 1, 0, -1]
    static let coss: [Float] = [1, 0, -1, 0]
    static let sincoss = zip(sins, coss)

    // SIMD doesn't have int3x3 or some of the other convenience methods, so it's simple to just use float3x3 for now
    // Perhaps losing a bunch of performance, but it's ok for now
    typealias Rotation = simd_float3x3

    static let rotx = sincoss.map { s, c -> Rotation in
        Rotation([
            simd_float3(1, 0, 0),
            simd_float3(0, c, -s),
            simd_float3(0, s, c),
        ])
    }

    static let roty = sincoss.map { s, c -> Rotation in
        Rotation([
            simd_float3(c, 0, s),
            simd_float3(0, 1, 0),
            simd_float3(-s, 0, c),
        ])
    }

    static let rotz = sincoss.map { s, c -> Rotation in
        Rotation([
            simd_float3(c, -s, 0),
            simd_float3(s, c, 0),
            simd_float3(0, 0, 1),
        ])
    }

    static let tripples: [[Rotation]] = product(rotx, product(roty, rotz)).map { [$0.0, $0.1.0, $0.1.1] }
    static let combinedRotations: [Rotation] = tripples
        .flatMap { $0.permutations(ofCount: 3).map { $0[0] * $0[1] * $0[2] } }
        .map(removeSignedZeros)
    static let allRotations = combinedRotations.uniqued(on: stringM)

    static func removeSignedZeros(_ r: Rotation) -> Rotation {
        Rotation(simd_float3(simd_int3(r.columns.0)),
                 simd_float3(simd_int3(r.columns.1)),
                 simd_float3(simd_int3(r.columns.2)))
    }

    static func rotateIndex3(_ v: Position, _ r: Rotation) -> Position {
        Position(r * SIMD3<Float>(v))
    }

    static func stringM(_ m: Rotation) -> String {
        String(format: "[(%2.0f,%2.0f,%2.0f), (%2.0f,%2.0f,%2.0f), (%2.0f,%2.0f,%2.0f)]",
               m[0, 0], m[1, 0], m[2, 0],
               m[0, 1], m[1, 1], m[2, 1],
               m[0, 2], m[1, 2], m[2, 2])
    }

    static func stringI(_ i: Position) -> String {
        String(format: "(%2d,%2d,%2d)", i.x, i.y, i.z)
    }
}
