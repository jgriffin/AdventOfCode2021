//
// Created by John Griffin on 12/23/21
//

import AdventOfCode2021
import XCTest

final class CuboidTreeTests: XCTestCase {
    func testCuboidTreeXCut() {
        let zero2four_five2nine_ten2fourteen = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 10 ... 14)
        let two_five2nine_ten2fourteen = Cuboid(x: 2 ... 2, y: 5 ... 9, z: 5 ... 14)
        let zero2to1_five2nine_ten2fourteen = Cuboid(x: 0 ... 1, y: 5 ... 9, z: 10 ... 14)
        let three2four_five2nine_ten2fourteen = Cuboid(x: 3 ... 4, y: 5 ... 9, z: 10 ... 14)

        var tree = CuboidTree()
        XCTAssertEqual(tree.onCount(), 0)

        tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
        XCTAssertEqual(tree.onCuboids(), [zero2four_five2nine_ten2fourteen])
        XCTAssertEqual(tree.onCount(), 5 * 5 * 5)

        tree.setCuboid(two_five2nine_ten2fourteen, on: false)
        XCTAssertEqual(tree.onCuboids(), [
            zero2to1_five2nine_ten2fourteen,
            three2four_five2nine_ten2fourteen,
        ])
        XCTAssertEqual(tree.onCount(), 4 * 5 * 5)
    }

    func testCuboidTreeXYZCuts() {
        let zero2four_five2nine_ten2fourteen = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 10 ... 14)
        let two_five2nine_ten2fourteen = Cuboid(x: 2 ... 2, y: 5 ... 9, z: 10 ... 14)
        let zero2four_six_ten2fourteen = Cuboid(x: 0 ... 4, y: 6 ... 6, z: 10 ... 14)
        let zero2four_five2nine_eleven = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 11 ... 11)

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(two_five2nine_ten2fourteen, on: false)
            XCTAssertEqual(tree.onCount(), 4 * 5 * 5)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(zero2four_six_ten2fourteen, on: false)
            XCTAssertEqual(tree.onCount(), 4 * 5 * 5)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(zero2four_five2nine_eleven, on: false)

            XCTAssertEqual(tree.onCount(), 4 * 5 * 5)
        }
    }

    func testCuboidTreeXYZPartialCuts() {
        let zero2four_five2nine_ten2fourteen = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 10 ... 14)
        let two_six2nine_ten2fourteen = Cuboid(x: 2 ... 2, y: 6 ... 9, z: 10 ... 14)
        let zero2four_six_eleven2fourteen = Cuboid(x: 0 ... 4, y: 6 ... 6, z: 11 ... 14)
        let one2four_five2nine_eleven = Cuboid(x: 1 ... 4, y: 5 ... 9, z: 11 ... 11)

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(two_six2nine_ten2fourteen, on: false)
            XCTAssertEqual(tree.onCount(), 5 * 5 * 5 - 1 * 4 * 5)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(zero2four_six_eleven2fourteen, on: false)
            XCTAssertEqual(tree.onCount(), 5 * 5 * 5 - 5 * 1 * 4)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(one2four_five2nine_eleven, on: false)

            XCTAssertEqual(tree.onCount(), 5 * 5 * 5 - 4 * 5 * 1)
        }
    }

    func testCuboidTreeAdds() {
        let zero2four_five2nine_ten2fourteen = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 10 ... 14)
        let two_five2nine_ten2fourteen = Cuboid(x: 2 ... 2, y: 5 ... 9, z: 10 ... 14)
        let zero2four_six_ten2fourteen = Cuboid(x: 0 ... 4, y: 6 ... 6, z: 10 ... 14)
        let zero2four_five2nine_eleven = Cuboid(x: 0 ... 4, y: 5 ... 9, z: 11 ... 11)

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(two_five2nine_ten2fourteen, on: true)
            XCTAssertEqual(tree.onCount(), 5 * 5 * 5)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(zero2four_six_ten2fourteen, on: true)
            XCTAssertEqual(tree.onCount(), 5 * 5 * 5)
        }

        do {
            var tree = CuboidTree()
            tree.setCuboid(zero2four_five2nine_ten2fourteen, on: true)
            tree.setCuboid(zero2four_five2nine_eleven, on: true)

            XCTAssertEqual(tree.onCount(), 5 * 5 * 5)
        }
    }

    func testCuboidCount() {
        let count = Self.fiftiesCuboid.count()
        XCTAssertEqual(count, 1_030_301)
    }

    static let fiftiesCuboid = Cuboid(x: -50 ... 50,
                                      y: -50 ... 50,
                                      z: -50 ... 50)
}
