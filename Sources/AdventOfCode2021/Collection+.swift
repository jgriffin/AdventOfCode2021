//
//
// Created by John Griffin on 12/13/21
//

import Foundation

public extension Collection where Element: Hashable {
    var asSet: Set<Self.Element> { Set(self) }
}

public extension Collection {
    var asArray: [Self.Element] { Array(self) }
    var asString: String { map { "\($0)" }.joined(separator: ", ") }
}
