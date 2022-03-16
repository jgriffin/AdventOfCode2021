//
// Created by John Griffin on 12/29/21
//

import Foundation

// return Greatest common devisor using the  Euclidean Algorithm
public func GCD<T: BinaryInteger>(_ a: T, _ b: T) -> T {
    if a == 0 { return b }
    if b == 0 { return a }

    // a = b * q + r
    let r = a % b
    return GCD(b, r)
}
