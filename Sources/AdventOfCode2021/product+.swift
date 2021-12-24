//
// Created by John Griffin on 12/22/21
//

import Algorithms

public func product3<Base1: Sequence, Base2: Collection, Base3: Collection>(
    _ s1: Base1, _ s2: Base2, _ s3: Base3
) -> [(Base1.Element, Base2.Element, Base3.Element)] {
    product(s1, product(s2, s3)).map { ($0, $1.0, $1.1) }
}
