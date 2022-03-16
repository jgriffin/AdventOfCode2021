//
// Created by John Griffin on 1/2/22
//

import Algorithms

public func productMany<T>(_ at: [T], count: Int) -> [[T]] {
    let p1: [[T]] = at.map { [$0] }
    let result = (1 ..< count).reduce(p1) { result, _ in
        product(result, at).map { ts, t in
            ts + [t]
        }
    }
    return result
}
