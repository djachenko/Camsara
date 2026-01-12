//
//  CVPixelBuffer+Extension.swift
//  Camsara
//
//  Created by justin on 12/1/26.
//

import CoreVideo


extension CVPixelBuffer {
    func downsamplePixelBuffer(
        maxPixelsToSample: Int
    ) -> [RGBColor] {
        let buffer = self

        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return [] }

        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)

        let pixelBuffer = base.assumingMemoryBound(to: UInt8.self)

        // 1️⃣ Стабильный step
        let target = max(1, maxPixelsToSample)
        let rawStep = sqrt(Double(width * height) / Double(target))

        // округляем, чтобы шаг не дрожал
        let step = max(1, Int(rawStep.rounded()))

        // Возможно, здесь нужны нули, но пока оставлю
        let offsetX = step / 2
        let offsetY = step / 2

        var pixels: [RGBColor] = []
        pixels.reserveCapacity(target)

        for y in stride(from: offsetY, to: height, by: step) {
            let row = y * bytesPerRow

            for x in stride(from: offsetX, to: width, by: step) {
                let offset = row + x * 4

                let b = Double(pixelBuffer[offset]) / 255
                let g = Double(pixelBuffer[offset + 1]) / 255
                let r = Double(pixelBuffer[offset + 2]) / 255
                //            let a = Double(pixelBuffer[offset + 3]) / 255

                pixels.append(RGBColor(r: r, g: g, b: b))
            }
        }

        return pixels
    }
}
