//
//
// Created by John Griffin on 12/11/21
//

import Foundation

public protocol Neighborly {
    static func + (_: Self, offset: (Int, Int)) -> Self
}

public extension Neighborly {
    typealias IsValidIndex = (Self) -> Bool

    typealias NeighborsOf = (Self) -> [Self]

    static func neighborsFunc(offsets: [(Int, Int)]) -> NeighborsOf {
        { index in offsets.map { index + $0 } }
    }

    static func neighborsFunc(
        offsets: [(Int, Int)],
        isValidIndex: @escaping IsValidIndex
    ) -> NeighborsOf {
        let neighborsOf = neighborsFunc(offsets: offsets)
        return { index in
            neighborsOf(index)
                .filter(isValidIndex)
        }
    }

    static var squareNeighborOffsets: [(Int, Int)] {
        [
            (0, -1),
            (-1, 0), (1, 0),
            (0, 1),
        ]
    }

    static var squareNeighborHoodOffsets: [(Int, Int)] {
        [
            (0, -1),
            (-1, 0), (0, 0), (1, 0),
            (0, 1),
        ]
    }

    static var diagonalNeighborOffsets: [(Int, Int)] {
        [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1), (0, 1),
            (1, -1), (1, 0), (1, 1),
        ]
    }

    static var diagonalNeighoodOffsets: [(Int, Int)] {
        [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1), (0, 0), (0, 1),
            (1, -1), (1, 0), (1, 1),
        ]
    }
}
