//
// Created by John Griffin on 12/24/21
//

import Foundation

public struct BinaryHeap<Value> {
    // Comparison determine a min/max heap
    public typealias HeapInvariant = (Value, Value) -> Bool
    let invariant: HeapInvariant

    public var heap: [Value] = []

    public init(invariant: @escaping HeapInvariant) {
        self.invariant = invariant
    }

    public init(minHeap: Bool) where Value: Comparable {
        if minHeap {
            self.init(invariant: <)
        } else {
            self.init(invariant: >)
        }
    }
}

public extension BinaryHeap {
    mutating func insert(_ v: Value) {
        heap.append(v)

        // Fix the heap invariant
        percolateDown(heap.count - 1)
    }

    mutating func removeFirst() -> Value? {
        guard !heap.isEmpty else { return nil }
        return remove(at: 0)
    }

    mutating func remove(at i: Int) -> Value {
        let value = heap[i]

        let last = heap.removeLast()
        guard !heap.isEmpty else {
            return value
        }

        // "swap" last into i
        heap[i] = last

        // Fix the heap invariant
        percolateUp(i)

        return value
    }
}

extension BinaryHeap {
    var isEmpty: Bool { heap.isEmpty }

    func parent(_ i: Int) -> Int? {
        guard i > 0 else { return nil }
        return (i - 1) / 2
    }

    func leftChild(_ i: Int) -> Int? {
        let iLeft = 2 * i + 1
        guard iLeft < heap.count else { return nil }
        return iLeft
    }

    func rightChild(_ i: Int) -> Int? {
        let iRight = 2 * i + 2
        guard iRight < heap.count else { return nil }
        return iRight
    }

    // percolateDown
    // maintain heap invariant by swapping with parent as needed
    mutating func percolateUp(_ i: Int) {
        var i = i
        while let iLeft = leftChild(i),
              let iRight = rightChild(i),
              !(invariant(heap[i], heap[iLeft]) &&
                  invariant(heap[i], heap[iRight]))
        {
            let betterChild = invariant(heap[iLeft], heap[iRight]) ? iLeft : iRight
            heap.swapAt(i, betterChild)
            i = betterChild
        }

        // Might still have left child remaining
        if let iLeft = leftChild(i), !invariant(heap[i], heap[iLeft]) {
            heap.swapAt(i, iLeft)
        }
    }

    // percolateDown
    // maintain heap invariant by swapping with parent as needed
    mutating func percolateDown(_ i: Int) {
        var i = i
        while let iParent = parent(i),
              !invariant(heap[iParent], heap[i])
        {
            heap.swapAt(iParent, i)
            i = iParent
        }
    }
}
