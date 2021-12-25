//
//
// Created by John Griffin on 12/15/21
//

import Collections
import Foundation

public struct AStar<Node: Hashable, Edge> {
    public typealias Path = [(n: Node, e: Edge?, c: Cost)]
    public typealias Cost = Int

    public typealias NodeEdgeAndCost = (n: Node, e: Edge, c: Cost)
    public typealias NeighborsOf = (Node) -> [NodeEdgeAndCost]

    public init(
        neighborsOf: @escaping NeighborsOf,
        h: @escaping (_ from: Node, _ goal: Node) -> Int
    ) {
        self.neighborsOf = neighborsOf
        self.h = h
    }

    let neighborsOf: NeighborsOf
    let h: (_ from: Node, _ goal: Node) -> Int

    typealias BestCost = (g: Int, from: NodeEdgeAndCost?)
    typealias IndexAndBestCost = (index: Node, cost: BestCost)
    typealias EstimatedCost = (f: Int, indexAndCost: IndexAndBestCost)

    public func findBestPath(start: Node, goal: Node) -> Path? {
        var open = Set<Node>([start])
        var bestCosts: [Node: BestCost] = [start: BestCost(g: 0, from: nil)]

        let fQueue = PriorityQueue<Node, Int>()
        fQueue.enqueue(start, priority: h(start, goal))

        func nextWithBestFInOpen() -> Node? {
            while let next = fQueue.popNext() {
                if open.contains(next) {
                    return next
                }
            }
            return nil
        }

        while let curr = nextWithBestFInOpen() {
            if curr == goal {
                return recreatePath(to: curr, bestCosts: bestCosts)
            }

            let bestCurr = bestCosts[curr]!

            neighborsOf(curr).forEach { n, e, c in
                let bcT = BestCost(g: bestCurr.g + c, from: (curr, e, c))
                guard bcT.g < bestCosts[n]?.g ?? .max else { return }

                bestCosts[n] = bcT
                fQueue.enqueue(n, priority: bcT.g + h(n, goal))
                open.insert(n)
            }

            open.remove(curr)
        }

        return nil
    }

    func recreatePath(to: Node, bestCosts: [Node: BestCost]) -> Path {
        var path: Path = []

        var to = to
        while let from = bestCosts[to]?.from {
            path.append((to, from.e, from.c))
            to = from.n
        }
        path.append((to, nil, 0))

        return path.reversed()
    }
}
