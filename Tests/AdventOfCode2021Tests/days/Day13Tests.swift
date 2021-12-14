//
//
// Created by John Griffin on 12/13/21
//

import AdventOfCode2021
import Parsing
import XCTest

final class Day13Tests: XCTestCase {
    let input = resourceURL(filename: "Day13Input.txt")!.readContents()!

    var example: String {
        """
        6,10
        0,14
        9,10
        0,3
        10,4
        4,11
        6,0
        6,12
        4,1
        0,13
        10,12
        3,4
        3,0
        8,4
        1,10
        2,14
        8,10
        9,0

        fold along y=7
        fold along x=5
        """
    }

    func testFoldPaperExample() {
        let (dots, folds) = Self.instructionsParser.parse(example)!
        let paper = Paper.fromDots(dots)

        let oneFold = folds.prefix(1).reduce(paper) { paper, fold in
            paper.folded(fold)
        }
        XCTAssertEqual(oneFold.dots.count, 17)

        let allFolds = folds.prefix(1).reduce(paper) { paper, fold in
            paper.folded(fold)
        }
        XCTAssertEqual(allFolds.dots.count, 17)
        print(allFolds.description, "\n")
    }

    func testFoldPaperInput() {
        let (dots, folds) = Self.instructionsParser.parse(input)!
        let paper = Paper.fromDots(dots)

        let oneFold = folds.prefix(1).reduce(paper) { paper, fold in
            paper.folded(fold)
        }
        XCTAssertEqual(oneFold.dots.count, 675)

        let allFolds = folds.reduce(paper) { paper, fold in
            paper.folded(fold)
        }
        XCTAssertEqual(allFolds.dots.count, 98)
        print(allFolds.description, "\n")
    }

    // MARK: - parser

    func testParseExample() {
        let (dots, folds) = Self.instructionsParser.parse(example)!
        XCTAssertEqual(dots.count, 18)
        XCTAssertEqual(dots.last, Index(9, 0))
        XCTAssertEqual(folds.count, 2)
        XCTAssertEqual(folds.last, .x(5))
    }

    func testParseInput() {
        let (dots, folds) = Self.instructionsParser.parse(input)!
        XCTAssertEqual(dots.count, 791)
        XCTAssertEqual(dots.last, Index(774, 285))
        XCTAssertEqual(folds.count, 12)
        XCTAssertEqual(folds.last, .y(6))
    }

    static let intParser = Prefix(1..., while: { $0.isNumber }).utf8.map { Int($0)! }
    static let dotParser = intParser.skip(",".utf8).take(intParser).map { Index($0, $1) }
    static let dotsParser = Many(dotParser, separator: "\n".utf8)

    enum Fold: Equatable {
        case x(Int)
        case y(Int)
    }

    static let foldXParser = Skip("fold along x=").utf8.take(intParser).map { Fold.x($0) }
    static let foldYParser = Skip("fold along y=").utf8.take(intParser).map { Fold.y($0) }
    static let foldParser = foldXParser.orElse(foldYParser)
    static let foldsParser = Many(foldParser, separator: "\n".utf8)

    static let instructionsParser = dotsParser.skip("\n\n".utf8).take(foldsParser)
        .map { dots, folds in (dots: dots, folds: folds) }
}

extension Day13Tests {
    typealias Index = IndexXY

    struct Paper: CustomStringConvertible {
        let size: Index
        let dots: Set<Index>

        static func fromDots(_ dots: [Index]) -> Paper {
            Paper(
                size: Index(dots.map(\.x).max()! + 1, dots.map(\.y).max()! + 1),
                dots: dots.asSet
            )
        }

        var description: String {
            (0 ..< size.y).map { y in
                (0 ..< size.x).map { x in
                    dots.contains(Index(x, y)) ? "*" : "."
                }
                .joined()
            }.joined(separator: "\n")
        }

        func folded(_ fold: Fold) -> Paper {
            switch fold {
            case let .x(fold): return folded(atX: fold)
            case let .y(fold): return folded(atY: fold)
            }
        }

        func folded(atX fold: Int) -> Paper {
            let indexMap = indexMapFoldAtX(fold)
            return Paper(
                size: Index(fold, size.y),
                dots: dots.map(indexMap).asSet
            )
        }

        func folded(atY fold: Int) -> Paper {
            let indexMap = indexMapFoldAtY(fold)
            return Paper(
                size: Index(size.x, fold),
                dots: dots.map(indexMap).asSet
            )
        }

        func indexMapFoldAtX(_ fold: Int) -> (Index) -> Index {
            { i in
                guard i.x > fold else { return i }
                return Index(fold - (i.x - fold), i.y)
            }
        }

        func indexMapFoldAtY(_ fold: Int) -> (Index) -> Index {
            { i in
                guard i.y > fold else { return i }
                return Index(i.x, fold - (i.y - fold)) }
        }
    }
}
