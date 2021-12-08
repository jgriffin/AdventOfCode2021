
func memoize<X: Hashable, Y>(
    work: @escaping (X) -> Y
) -> (X) -> Y {
    var memo = [X: Y]()

    return { x in
        if let q = memo[x] {
            return q
        }

        let result = work(x)
        memo[x] = result
        return result
    }
}

func memoizeRecursive<X: Hashable, Y>(
    work: @escaping (X, _ recurse: (X) -> Y) -> Y
) -> (X) -> Y {
    var memo = [X: Y]()

    func wrap(x: X) -> Y {
        if let q = memo[x] { return q }
        let r = work(x, wrap)
        memo[x] = r
        return r
    }

    return wrap
}
