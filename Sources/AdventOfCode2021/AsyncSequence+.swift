//
// Created by John Griffin on 12/31/21
//

public extension AsyncSequence {
    func collect() async rethrows -> [Element] {
        try await reduce(into: [Element]()) { $0.append($1) }
    }

    func first() async rethrows -> Element? {
        for try await e in self {
            return e
        }
        return nil
    }
}
