//
//
// Created by John Griffin on 12/15/21
//

import Foundation

public struct AStar<Index: Indexable2> {
    public typealias Path = [Index]

    public init(
        neighbors: @escaping (Index) -> [Index],
        stepCostTo: @escaping (_ to: Index, _ from: Index?) -> Int,
        h: @escaping (_ from: Index, _ goal: Index) -> Int
    ) {
        self.neighbors = neighbors
        self.stepCostTo = stepCostTo
        self.h = h
    }

    let neighbors: (Index) -> [Index]
    let stepCostTo: (_ to: Index, _ from: Index?) -> Int
    let h: (_ from: Index, _ goal: Index) -> Int

    typealias BestCost = (g: Int, from: Index?)
    typealias IndexAndBestCost = (index: Index, cost: BestCost)
    typealias EstimatedCost = (f: Int, indexAndCost: IndexAndBestCost)

    public func findBestPath(start: Index, goal: Index) -> Path? {
        var open = Set<Index>([start])

        var bestSoFar: [Index: BestCost] = [start: (0, nil)]
        var f: [Index: Int] = [start: h(start, goal)]

        func nextWithBestFInOpen() -> Index? {
            typealias BestF = (f: Int, i: Index)

            var bestF: Int = .max
            var bestIndex: Index = .invalid
            for o in open {
                guard let f = f[o] else { fatalError() }
                if f < bestF {
                    bestF = f
                    bestIndex = o
                }
            }

            return bestIndex
        }

        while let curr = nextWithBestFInOpen() {
            if curr == goal {
                return recreatePath(to: curr, bestPaths: bestSoFar)
            }

            let bestCurr = bestSoFar[curr]!

            neighbors(curr).forEach { n in
                let bcT = BestCost(g: bestCurr.g + stepCostTo(n, bestCurr.from), from: curr)
                guard bcT.g < bestSoFar[n]?.g ?? .max else { return }

                bestSoFar[n] = bcT
                f[n] = bcT.g + h(n, goal)
                open.insert(n)
            }

            open.remove(curr)
        }

        return nil
    }

    func recreatePath(to: Index, bestPaths: [Index: BestCost]) -> Path {
        var path: Path = [to]

        var from = bestPaths[to]?.from

        while let next = from {
            path.append(next)
            from = bestPaths[next]?.from
        }

        return path.reversed()
    }
}
