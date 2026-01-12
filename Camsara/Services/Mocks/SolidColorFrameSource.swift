//
//  SolidColorFrameSource.swift
//  Camsara
//
//  Created by justin on 12/1/26.
//


import AVFoundation
import Combine
import UIKit

final class SolidColorFrameSource: FrameSource {

    private let subject = PassthroughSubject<CMSampleBuffer, Never>()
    private var timer: Timer?

    var framePublisher: AnyPublisher<CMSampleBuffer, Never> {
        subject.eraseToAnyPublisher()
    }

    init(
        color: UIColor,
        size: CGSize = CGSize(width: 640, height: 480),
        fps: Double = 30.0
    ) {
        let pixelBuffer = Self.makePixelBuffer(color: color, size: size)
        let sampleBuffer = Self.makeSampleBuffer(from: pixelBuffer)

        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / fps,
            repeats: true
        ) { [weak self] _ in
            self?.subject.send(sampleBuffer)
        }
    }

    deinit {
        timer?.invalidate()
    }
}

private extension SolidColorFrameSource {
    static func makePixelBuffer(
        color: UIColor,
        size: CGSize
    ) -> CVPixelBuffer {
        let width = Int(size.width)
        let height = Int(size.height)

        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        ]

        var buffer: CVPixelBuffer!

        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &buffer
        )

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
            fatalError("No base address")
        }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)

        // RGBA из UIColor
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let B = UInt8(b * 255)
        let G = UInt8(g * 255)
        let R = UInt8(r * 255)
        let A = UInt8(a * 255)

        let ptr = baseAddress.assumingMemoryBound(to: UInt8.self)

        for y in 0..<height {
            let row = ptr + y * bytesPerRow

            for x in 0..<width {
                let offset = x * 4

                row[offset + 0] = B
                row[offset + 1] = G
                row[offset + 2] = R
                row[offset + 3] = A
            }
        }

        return buffer
    }
}


private extension SolidColorFrameSource {

    static func makeSampleBuffer(
        from pixelBuffer: CVPixelBuffer
    ) -> CMSampleBuffer {

        var formatDescription: CMVideoFormatDescription!
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )

        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: 30),
            presentationTimeStamp: .zero,
            decodeTimeStamp: .invalid
        )

        var sampleBuffer: CMSampleBuffer!
        CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )

        return sampleBuffer
    }
}
