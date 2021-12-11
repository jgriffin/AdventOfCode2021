//
//
// Created by John Griffin on 12/10/21
//

import Foundation

// sometimes we think in terms of XY
// sometimes we think in terms of rows and columns
// but there's a lot in common between IndexXY and IndexRC, so we have Indexable2

public struct IndexXY: Indexable2, Hashable {
    public let x, y: Int

    public init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    public init(x: Int, y: Int) { self.init(x, y) }

    public var first: Int { x }
    public var second: Int { y }

    public static func isValidIndexFunc(
        rowIndices: Range<Int>,
        colIndices: Range<Int>
    ) -> IsValidIndex {
        { index in
            rowIndices.contains(index.y) && colIndices.contains(index.x)
        }
    }
}

public struct IndexRC: Indexable2, Hashable {
    public let r, c: Int

    public init(_ r: Int, _ y: Int) {
        self.r = r
        c = y
    }

    public init(r: Int, c: Int) { self.init(r, c) }

    public var first: Int { r }
    public var second: Int { c }

    public static func isValidIndexFunc(
        rowIndices: Range<Int>,
        colIndices: Range<Int>
    ) -> IsValidIndex {
        { index in
            rowIndices.contains(index.r) && colIndices.contains(index.c)
        }
    }
}

public protocol Indexable2: Neighborly {
    init(_ first: Int, _ second: Int)
    var first: Int { get }
    var second: Int { get }
}

public extension Indexable2 {
    init(_ pair: (Int, Int)) { self.init(pair.0, pair.1) }

    var description: String { "(\(first),\(second))" }

    typealias IsValidIndex = (Self) -> Bool

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(lhs.first + rhs.first, lhs.second + rhs.second)
    }

    static func + (lhs: Self, offset: (Int, Int)) -> Self {
        .init(lhs.first + offset.0, lhs.second + offset.1)
    }

    static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    static func += (lhs: inout Self, offset: (Int, Int)) { lhs = lhs + offset }
}
