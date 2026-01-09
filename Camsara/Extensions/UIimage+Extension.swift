//
//  UIImage+Extension.swift
//  Camsara
//
//  Created by justin on 06.01.2026.
//

import UIKit


extension UIImage {
    func pixelColors(step: Int = 8) -> [UIColor]? {
        guard let cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var colors: [UIColor] = []
        colors.reserveCapacity((width / step) * (height / step))

        autoreleasepool {
            for y in stride(from: 0, to: height, by: step) {
                for x in stride(from: 0, to: width, by: step) {
                    let index = (y * width + x) * 4

                    let r = CGFloat(pixels[index]) / 255
                    let g = CGFloat(pixels[index + 1]) / 255
                    let b = CGFloat(pixels[index + 2]) / 255
                    let a = CGFloat(pixels[index + 3]) / 255

                    colors.append(UIColor(red: r, green: g, blue: b, alpha: a))
                }
            }
        }

        return colors
    }
}
