//
//  MedianCutAlgorithm.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import UIKit


final class MedianCutAlgorithm: PaletteAlgorithm {
    let name = "Median Cut"

    func extractColors(
        from pixelBuffer: CVPixelBuffer,
        maxColors: Int,
        options: ProcessingOptions
    ) -> [RGBColor] {
        let pixels = pixelBuffer.downsamplePixelBuffer(maxPixelsToSample: options.maxPixelsToSample)

        guard !pixels.isEmpty else {
            return []
        }

        var blocks = [ColorBlock(pixels: pixels)]

        while blocks.count < maxColors && blocks.count < pixels.count {
            guard let blockToSplit = blocks.max(by: { $0.range < $1.range }) else {
                break
            }

            let (block1, block2) = splitColorBlock(blockToSplit)
            blocks.removeAll { $0.id == blockToSplit.id }
            blocks.append(contentsOf: [block1, block2])
        }

        var colors = blocks.map { averageColor($0.pixels) }

        // Фильтрация по размеру блока
        let totalPixels = pixels.count

        colors = colors.enumerated().compactMap { idx, color in
            let blockSize = blocks[idx].pixels.count

            if Double(blockSize) / Double(totalPixels) >= options.minClusterPercentage {
                return color
            }

            return nil
        }

        return colors
    }
}

private struct ColorBlock {
    let id = UUID()
    let pixels: [RGBColor]

    var range: Double {
        var minR = 1.0
        var minG = 1.0
        var minB = 1.0

        var maxR = 0.0
        var maxG = 0.0
        var maxB = 0.0

        for pixel in pixels {
            minR = min(minR, pixel.r)
            maxR = max(maxR, pixel.r)
            minG = min(minG, pixel.g)
            maxG = max(maxG, pixel.g)
            minB = min(minB, pixel.b)
            maxB = max(maxB, pixel.b)
        }

        let rRange = maxR - minR
        let gRange = maxG - minG
        let bRange = maxB - minB

        return max(rRange, gRange, bRange)
    }
}

private func splitColorBlock(_ block: ColorBlock) -> (ColorBlock, ColorBlock) {
    // Находим канал с наибольшим диапазоном
    var minR: Double = 1, maxR: Double = 0
    var minG: Double = 1, maxG: Double = 0
    var minB: Double = 1, maxB: Double = 0

    for pixel in block.pixels {
        minR = min(minR, pixel.r)
        maxR = max(maxR, pixel.r)
        minG = min(minG, pixel.g)
        maxG = max(maxG, pixel.g)
        minB = min(minB, pixel.b)
        maxB = max(maxB, pixel.b)
    }

    let rRange = maxR - minR
    let gRange = maxG - minG
    let bRange = maxB - minB

    // Сортируем по выбранному каналу с вторичными ключами для стабильности
    var sortedPixels = block.pixels

    if rRange >= gRange && rRange >= bRange {
        sortedPixels.sort { c1, c2 in
            if c1.r != c2.r { return c1.r < c2.r }
            if c1.g != c2.g { return c1.g < c2.g }
            return c1.b < c2.b
        }
    } else if gRange >= rRange && gRange >= bRange {
        sortedPixels.sort { c1, c2 in
            if c1.g != c2.g { return c1.g < c2.g }
            if c1.b != c2.b { return c1.b < c2.b }
            return c1.r < c2.r
        }
    } else {
        sortedPixels.sort { c1, c2 in
            if c1.b != c2.b { return c1.b < c2.b }
            if c1.r != c2.r { return c1.r < c2.r }
            return c1.g < c2.g
        }
    }

    let mid = sortedPixels.count / 2
    let block1 = ColorBlock(pixels: Array(sortedPixels[0..<mid]))
    let block2 = ColorBlock(pixels: Array(sortedPixels[mid..<sortedPixels.count]))

    return (block1, block2)
}

private func averageColor(_ colors: [RGBColor]) -> RGBColor {
    guard !colors.isEmpty else { return .black }

    var r: Double = 0, g: Double = 0, b: Double = 0

    for color in colors {
        r += color.r
        g += color.g
        b += color.b
    }

    let count = Double(colors.count)

    return RGBColor(
        r: r / count,
        g: g / count,
        b: b / count,
    )
}
