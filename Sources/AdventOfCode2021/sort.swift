//
// Created by John Griffin on 12/30/21
//

import Foundation

public func inIncreasingOrderWithSecondary<T>(
    primary: @escaping (T, T) -> Bool,
    secondary: @escaping (T, T) -> Bool
) -> (T, T) -> Bool {
    { lhs, rhs in
        let p = primary(lhs, rhs)
        let pFlip = primary(rhs, lhs)

        guard p != pFlip else {
            // must be equal, use secondary
            return secondary(lhs, rhs)
        }
        return p
    }
}
