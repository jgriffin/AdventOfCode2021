//
//
// Created by John Griffin on 12/11/21
//

public extension RandomAccessCollection
    where Indices == Range<Int>, Element: RandomAccessCollection, Element.Indices == Range<Int>
{
    // MARK: - IndexXY

    func indexXYRanges() -> IndexXY.IndexRanges {
        (first!.indices, indices)
    }

    subscript(indexXY: IndexXY) -> Element.Element where Self: MutableCollection, Element: MutableCollection {
        get { self[indexXY.y][indexXY.x] }
        set { self[indexXY.y][indexXY.x] = newValue }
    }

    subscript(indexXY: IndexXY) -> Element.Element { self[indexXY.y][indexXY.x] }

    // MARK: - IndexRC

    func indexRCRanges() -> IndexRC.IndexRanges {
        (indices, first!.indices)
    }

    subscript(indexRC: IndexRC) -> Element.Element where Self: MutableCollection, Element: MutableCollection {
        get { self[indexRC.r][indexRC.c] }
        set { self[indexRC.r][indexRC.c] = newValue }
    }

    subscript(indexRC: IndexRC) -> Element.Element { self[indexRC.r][indexRC.c] }
}
