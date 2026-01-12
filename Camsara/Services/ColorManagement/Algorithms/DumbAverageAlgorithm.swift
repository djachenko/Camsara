//
//  DumbAverageAlgorithm.swift
//  Camsara
//
//  Created by justin on 12/1/26.
//

import CoreVideo
import Foundation


final class DumbAverageAlgorithm: PaletteAlgorithm {
    let name = "Dumb Average"

    func extractColors(from pixelBuffer: CVPixelBuffer, maxColors: Int, options: ProcessingOptions) -> [RGBColor] {
        let pixels = pixelBuffer.downsamplePixelBuffer(maxPixelsToSample: options.maxPixelsToSample)

        guard !pixels.isEmpty else {
            return []
        }

        var r = 0.0
        var g = 0.0
        var b = 0.0

        let count = Double(pixels.count)

        pixels.forEach {
            r += $0.r / count
            g += $0.g / count
            b += $0.b / count
        }

        print("rgb", r, g, b)

        return [
            RGBColor(r: r, g: g, b: b)
        ]
    }
}
