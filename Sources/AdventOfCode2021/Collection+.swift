//
//
// Created by John Griffin on 12/13/21
//

import Foundation

public extension Collection where Element: Hashable {
    var asSet: Set<Self.Element> { Set(self) }
}

public extension Sequence {
    var asArray: [Self.Element] { Array(self) }
    var asString: String { map(toString).joined(separator: ", ") }

    var toLines: String { map(toString).joined(separator: "\n") }
}

public func toString<T>(_ t: T) -> String { "\(t)" }
