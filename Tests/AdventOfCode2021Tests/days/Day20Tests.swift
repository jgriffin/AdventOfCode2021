//
// Created by John Griffin on 12/20/21
//

import AdventOfCode2021
import Algorithms
import Parsing
import XCTest

final class Day20Tests: XCTestCase {
    let input = resourceURL(filename: "Day20Input.txt")!.readContents()!

    var example: String {
        """
        ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

        #..#.
        #....
        ##..#
        ..#..
        ..###
        """
    }

    // MARK: - enhance fifty

    func testEnhanceFiftyExample() {
        let (enhancements, imageString) = Self.inputParser.parse(example)!
        let image = Image(imageString)
        let enhancer = Enhancer(enhancementPixels: enhancements.asArray)

        let enhanced = (0 ..< 50).reductions(image) { image, _ in
            enhancer.enhance(image)
        }

        XCTAssertEqual(enhanced.last?.whitePixels.count, 3351)
    }

    func testEnhanceInputExample() {
        let (enhancements, imageString) = Self.inputParser.parse(input)!
        let image = Image(imageString)
        let enhancer = Enhancer(enhancementPixels: enhancements.asArray)

        let enhanced = (0 ..< 50).reductions(image) { image, _ in
            enhancer.enhance(image)
        }

        XCTAssertEqual(enhanced.last?.whitePixels.count, 16793)
    }

    // MARK: - enhance twice

    func testEnhanceTwiceExample() {
        let (enhancements, imageString) = Self.inputParser.parse(example)!
        let image = Image(imageString)
        let enhancer = Enhancer(enhancementPixels: enhancements.asArray)

        let enhanced = (0 ..< 2).reductions(image) { result, _ in
            enhancer.enhance(result)
        }

        XCTAssertEqual(enhanced.last?.whitePixels.count, 35)
    }

    func testEnhanceTwiceInput() {
        let (enhancements, imageString) = Self.inputParser.parse(input)!
        let enhancer = Enhancer(enhancementPixels: enhancements.asArray)
        let image = Image(imageString)

        let enhanced = (0 ..< 2).reductions(image) { result, _ in
            enhancer.enhance(result)
        }

        XCTAssertEqual(enhanced.last?.whitePixels.count, 4968)
    }
}

extension Day20Tests {
    typealias Pixel = IndexXY

    struct Enhancer {
        let enhancementPixels: [Character]

        func enhance(_ i: Image) -> Image {
            let i = ensureBorder(i)

            var output = Set<Pixel>()
            let pixelRanges = i.pixelRanges

            product(pixelRanges.x, pixelRanges.y).map { Pixel($0, $1) }
                .forEach { p in
                    let c = i.convolutionScore(p)
                    if enhancementPixels[c] == Image.light {
                        output.insert(p)
                    }
                }

            let newImage = Image(output, pixelRanges: pixelRanges)
            return newImage
        }

        // with the infinite extents, we need a stable border, of at least two pixels
        func ensureBorder(_ i: Image) -> Image {
            let outerPixelRanges = i.pixelRanges
            let outerEdgePixels = edgePixels(in: outerPixelRanges)
            let outerEdgeIsWhite = i.isWhite(outerEdgePixels.first!)
            let hasConsistentOuterEdge = outerEdgePixels.allSatisfy { p in i.isWhite(p) == outerEdgeIsWhite }

            let innerPixelRanges = (x: outerPixelRanges.x.dropFirst().dropLast(), y: outerPixelRanges.y.dropFirst().dropLast())
            let innerEdgePixels = edgePixels(in: innerPixelRanges)
            let innerEdgeIsWhite = i.isWhite(innerEdgePixels.first!)
            let hasConsistentInnerEdge = innerEdgePixels.allSatisfy { p in i.isWhite(p) == outerEdgeIsWhite }

            if hasConsistentOuterEdge, hasConsistentInnerEdge, outerEdgeIsWhite == innerEdgeIsWhite {
                // we're ok, we've got a stable two pixel border
                return i
            }

            if !outerEdgeIsWhite || !hasConsistentOuterEdge {
                // just extend the edges with black
                let newPixelRange = (x: i.pixelRanges.x.lowerBound - 2 ..< i.pixelRanges.x.upperBound + 2,
                                     y: i.pixelRanges.y.lowerBound - 2 ..< i.pixelRanges.y.upperBound + 2)
                return Image(i.whitePixels, pixelRanges: newPixelRange)
            }

            // our edge is white, but we only have one, gotta add a bunch of pixels
            let newOuterPixelRange = (x: outerPixelRanges.x.lowerBound - 1 ..< outerPixelRanges.x.upperBound + 1,
                                      y: outerPixelRanges.y.lowerBound - 1 ..< outerPixelRanges.y.upperBound + 1)
            let newWhitePixels = i.whitePixels.union(edgePixels(in: newOuterPixelRange))
            let newImage = Image(newWhitePixels, pixelRanges: newOuterPixelRange)
            return newImage
        }

        func edgePixels(in ranges: Pixel.IndexRanges) -> [Pixel] {
            [
                ranges.x.dropLast()
                    .map { x in Pixel(x, ranges.y.lowerBound) },
                ranges.y.dropLast()
                    .map { y in Pixel(ranges.x.last!, y) },
                ranges.x.dropFirst().reversed()
                    .map { x in Pixel(x, ranges.y.last!) },
                ranges.y.dropFirst().reversed()
                    .map { y in Pixel(ranges.x.lowerBound, y) },
            ].flatMap { $0 }
        }
    }

    struct Image: CustomStringConvertible {
        let whitePixels: Set<Pixel>
        let pixelRanges: Pixel.IndexRanges

        static let light = Character("#")
        static let dark = Character(".")
        static let minimumPadding: Int = 3

        init(_ whitePixels: Set<Pixel>,
             pixelRanges: Pixel.IndexRanges)
        {
            self.whitePixels = whitePixels
            self.pixelRanges = pixelRanges
        }

        init(_ text: [Substring]) {
            var pixels = Set<Pixel>()

            for (y, pixelRow) in text.enumerated() {
                for (x, p) in pixelRow.enumerated() {
                    if p == Self.light {
                        pixels.insert(Pixel(x, y))
                    }
                }
            }

            self.init(
                pixels,
                pixelRanges: (x: 0 ..< text.first!.count,
                              y: 0 ..< text.count)
            )
        }

        var description: String {
            pixelRanges.y.map { y in
                String(
                    pixelRanges.x.map { x in
                        isWhite(Pixel(x, y)) ? Self.light : Self.dark
                    }
                )
            }.joined(separator: "\n")
        }

        func isWhite(_ p: Pixel) -> Bool { whitePixels.contains(p) }

        func convolutionScore(_ p: Pixel) -> Int {
            Self.convolutionOffsets
                .map { o in (p + o).ensureIn(pixelRanges) }
                .reduce(0) { result, p in
                    (result << 1) + (isWhite(p) ? 1 : 0)
                }
        }

        static var convolutionOffsets: [(Int, Int)] {
            [(-1, -1), (0, -1), (1, -1),
             (-1, 0), (0, 0), (1, 0),
             (-1, 1), (0, 1), (1, 1)]
        }
    }
}

extension Day20Tests {
    // MARK: - parser

    static func isPixelChar(_ c: Character) -> Bool { c == Image.light || c == Image.dark }

    static let enhancementPixelsParser = Prefix(512, while: isPixelChar).utf8
    static let imageStringParser = Many(Prefix(1..., while: isPixelChar).utf8, atLeast: 1, separator: "\n".utf8)
    static let inputParser = enhancementPixelsParser.skip("\n\n".utf8).take(imageStringParser)

    func testParseExample() {
        let (enhancement, inputImage) = Self.inputParser.parse(example)!
        XCTAssertNotNil(enhancement)
        XCTAssertNotNil(inputImage)
    }

    func testParseInput() {
        let (_, inputString) = Self.inputParser.parse(input)!
        XCTAssertEqual(inputString.count, 100)
        XCTAssertEqual(inputString.last?.suffix(5), "#.#.#")
    }
}
