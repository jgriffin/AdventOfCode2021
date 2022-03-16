//
// Created by John Griffin on 12/30/21
//

public struct Index3: Hashable, CustomStringConvertible {
    public let x, y, z: Int

    public var description: String { "(\(x),\(y),\(z))" }

    public static let zero = Index3(0, 0, 0)
}

public extension Index3 {
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func + (lhs: Self, offset: (Int, Int, Int)) -> Self {
        .init(lhs.x + offset.0, lhs.y + offset.1, lhs.z + offset.2)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    static func - (lhs: Self, offset: (Int, Int, Int)) -> Self {
        .init(lhs.x - offset.0, lhs.y - offset.1, lhs.z - offset.2)
    }

    static func += (lhs: inout Self, rhs: Self) { lhs = lhs + rhs }
    static func += (lhs: inout Self, offset: (Int, Int, Int)) { lhs = lhs + offset }
    static func -= (lhs: inout Self, rhs: Self) { lhs = lhs - rhs }
    static func -= (lhs: inout Self, offset: (Int, Int, Int)) { lhs = lhs - offset }
}
