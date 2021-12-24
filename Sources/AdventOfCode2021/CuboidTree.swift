//
// Created by John Griffin on 12/23/21
//

struct Index3D: Hashable {
    let x, y, z: Int
}

public struct Cuboid: Equatable {
    public let x, y, z: Range<Int>

    public init(x: Range<Int>, y: Range<Int>, z: Range<Int>) {
        self.x = x
        self.y = y
        self.z = z
    }

    public init(x: ClosedRange<Int>, y: ClosedRange<Int>, z: ClosedRange<Int>) {
        self.init(x: Range(x), y: Range(y), z: Range(z))
    }

    public func count(inRange: Cuboid? = nil) -> Int {
        guard let inRange = inRange else { return x.count * y.count * z.count }
        return x.clamped(to: inRange.x).count *
            y.clamped(to: inRange.y).count *
            z.clamped(to: inRange.z).count
    }

    func contains(_ i: Index3D) -> Bool {
        x.contains(i.x) && y.contains(i.y) && z.contains(i.z)
    }
}

public struct CuboidTree {
    typealias XTree = [XTreeNode]
    typealias YTree = [YTreeNode]
    typealias ZTree = [ZTreeNode]
    typealias XTreeNode = (x: Int, yT: YTree)
    typealias YTreeNode = (y: Int, zT: ZTree)
    typealias ZTreeNode = (z: Int, isOn: Bool)

    public init() {}

    var xTree: XTree = []

    public func onCuboids() -> [Cuboid] {
        let cuboids: [(c: Cuboid, isOn: Bool)] =
            xTree.adjacentPairs().flatMap { xTN, xTNNext in
                xTN.yT.adjacentPairs().flatMap { yTN, yTNNext in
                    yTN.zT.adjacentPairs().map { zTN, zTNNext in
                        (Cuboid(x: xTN.x ..< xTNNext.x,
                                y: yTN.y ..< yTNNext.y,
                                z: zTN.z ..< zTNNext.z),
                         isOn: zTN.isOn)
                    }
                }
            }

        return cuboids.compactMap { c, isOn -> Cuboid? in
            guard isOn else { return nil }
            return c
        }
    }

    public func onCount(inRange: Cuboid? = nil) -> Int {
        onCuboids().map { $0.count(inRange: inRange) }.reduce(0,+)
    }

    public mutating func setCuboid(_ c: Cuboid, on: Bool) {
        ensureTreeSplits(c)

        for (ix, xTN) in xTree.enumerated() where c.x.contains(xTN.x) {
            xTree[ix] = (xTN.x, yTreeSetting(yT: xTN.yT, y: c.y, z: c.z, on: on))
        }

        compact()
    }

    // MARK: helpers

    func yTreeSetting(yT: YTree, y: Range<Int>, z: Range<Int>, on: Bool) -> YTree {
        var yTree = yT
        for (iy, yTN) in yT.enumerated() where y.contains(yTN.y) {
            yTree[iy] = (yTN.y, zTreeSetting(zT: yTN.zT, z: z, on: on))
        }
        return yTree
    }

    func zTreeSetting(zT: ZTree, z: Range<Int>, on: Bool) -> ZTree {
        var zTree = zT
        for (iz, zTN) in zT.enumerated() where z.contains(zTN.z) {
            zTree[iz] = (zTN.z, on)
        }
        return zTree
    }

    // MARK: split

    // split - break up tree along cuboid edges
    mutating func ensureTreeSplits(_ c: Cuboid) {
        ensureXTreeSplit(xT: &xTree, atX: c.x.lowerBound)
        ensureXTreeSplit(xT: &xTree, atX: c.x.upperBound)

        for (ix, xTN) in xTree.enumerated() where c.x.contains(xTN.x) {
            ensureYTreeSplit(yT: &xTree[ix].yT, atY: c.y.lowerBound)
            ensureYTreeSplit(yT: &xTree[ix].yT, atY: c.y.upperBound)

            for (iy, yTN) in xTree[ix].yT.enumerated() where c.y.contains(yTN.y) {
                ensureZTreeSplit(zT: &xTree[ix].yT[iy].zT, atZ: c.z.lowerBound)
                ensureZTreeSplit(zT: &xTree[ix].yT[iy].zT, atZ: c.z.upperBound)
            }
        }
    }

    func ensureXTreeSplit(xT: inout XTree, atX: Int) {
        let ix = xT.firstIndex { x, _ in atX <= x }
        switch ix {
        case let .some(ix) where xT[ix].x == atX:
            break
        case 0:
            // add empty at start
            xT.insert(XTreeNode(atX, []), at: 0)
        case let .some(ix):
            // split - copy previous yT
            xT.insert(XTreeNode(atX, xT[ix - 1].yT), at: ix)
        case .none:
            xT.append(XTreeNode(atX, xT.last?.yT ?? []))
        }
    }

    func ensureYTreeSplit(yT: inout YTree, atY: Int) {
        let iy = yT.firstIndex { y, _ in atY <= y }
        switch iy {
        case let .some(it) where yT[it].y == atY:
            break
        case 0:
            // add empty at start
            yT.insert(YTreeNode(atY, []), at: 0)
        case let .some(iy):
            // split - copy previous yT
            yT.insert(YTreeNode(atY, yT[iy - 1].zT), at: iy)
        case .none:
            yT.append(YTreeNode(atY, yT.last?.zT ?? []))
        }
    }

    func ensureZTreeSplit(zT: inout ZTree, atZ: Int) {
        let iz = zT.firstIndex { y, _ in atZ <= y }
        switch iz {
        case let .some(it) where zT[it].z == atZ:
            break
        case 0:
            // add empty at start
            zT.insert(ZTreeNode(atZ, false), at: 0)
        case let .some(iz):
            // split - copy previous yT
            zT.insert(ZTreeNode(atZ, zT[iz - 1].isOn), at: iz)
        case .none:
            zT.append(ZTreeNode(atZ, zT.last?.isOn ?? false))
        }
    }

    func compact() {
//            fatalError()
    }
}
