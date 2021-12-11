//
//
// Created by John Griffin on 12/10/21
//

import Algorithms

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

    public typealias IndexRanges = (x: Range<Int>, y: Range<Int>)
    public typealias IsValidIndex = (IndexXY) -> Bool

    public static func isValidIndexFunc(_ ranges: IndexXY.IndexRanges) -> IndexXY.IsValidIndex {
        { index in
            ranges.x.contains(index.x) && ranges.y.contains(index.y)
        }
    }

    public static func allIndexXY(_ xyRanges: IndexXY.IndexRanges) -> [IndexXY] {
        product(xyRanges.y, xyRanges.x).map { y, x in IndexXY(x: x, y: y) }
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

    public typealias IndexRanges = (r: Range<Int>, c: Range<Int>)
    public typealias IsValidIndex = (IndexRC) -> Bool

    public static func isValidIndexFunc(_ ranges: IndexRC.IndexRanges) -> IndexRC.IsValidIndex {
        { index in
            ranges.r.contains(index.r) && ranges.c.contains(index.c)
        }
    }

    public static func allIndexRC(_ ranges: IndexRC.IndexRanges) -> [IndexRC] {
        product(ranges.r, ranges.c).map { r, c in IndexRC(r: r, c: c) }
    }
}

public protocol Indexable2: Neighborly, CustomStringConvertible {
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
