//
//  StaticImageCameraService.swift
//  Camsara
//
//  Created by justin on 11/1/26.
//

import AVFoundation
import Combine
import UIKit


// MARK: - Mock Camera Service
final class StaticImageCameraService: NSObject, CameraService, FrameSource {
    let session = AVCaptureSession()

    @Published var frame: CMSampleBuffer?
    @Published var currentZoom: Double = 1.0

    var w2hRatio: Double = 16.0 / 9.0
    var deviceFocalLength: Double = 26.0 // 26mm для wide-angle
    var currentFocalLength: Double {
        currentZoom * deviceFocalLength
    }

    var framePublisher: AnyPublisher<CMSampleBuffer, Never> {
        $frame
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    private let sampleBuffer: CMSampleBuffer
    private var timer: Timer?
    private let frameRate: TimeInterval

    // MARK: - Initialization

    init?(image: UIImage, frameRate: TimeInterval = 30.0) {
        self.frameRate = frameRate

        // Создаем статичный sample buffer из изображения
        guard let sampleBuffer = StaticImageCameraService.createSampleBuffer(from: image, frameRate: frameRate) else {
            return nil
        }

        self.sampleBuffer = sampleBuffer
        super.init()

        // Начинаем "вещать" кадры
        self.startFrameDelivery()
    }

    // MARK: - CameraService Protocol

    func set(zoom: Double) {
        currentZoom = max(1.0, min(zoom, 10.0))
    }

    func set(focalLength: Double) {
        set(zoom: focalLength / deviceFocalLength)
    }

    func start() {
        startFrameDelivery()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Frame Generation

    private func startFrameDelivery() {
        stop() // Останавливаем предыдущий таймер

        let interval = 1.0 / frameRate

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else {
                return
            }

            // Каждый раз отдаем один и тот же буфер
            self.frame = self.sampleBuffer
        }
    }

    // MARK: - Deinit

    deinit {
        stop()
    }
}

// MARK: - Static Image Creation Utilities
extension StaticImageCameraService {
    /// Конвертирует UIImage в CMSampleBuffer
    static func createSampleBuffer(from image: UIImage, frameRate: TimeInterval) -> CMSampleBuffer? {
        guard let pixelBuffer = image.pixelBuffer() else {
            return nil
        }

        var formatDescription: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )

        guard status == noErr,
                let formatDescription = formatDescription else {
            return nil
        }

        var timingInfo = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: Int32(frameRate)),
            presentationTimeStamp: CMTime.zero,
            decodeTimeStamp: CMTime.invalid
        )

        var sampleBuffer: CMSampleBuffer?

        let createStatus = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: formatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        guard createStatus == noErr, let sampleBuffer = sampleBuffer else {
            return nil
        }

        return sampleBuffer
    }
}

// MARK: - UIImage Extension for PixelBuffer Creation
extension UIImage {

    /// Конвертирует UIImage в CVPixelBuffer
    func pixelBuffer() -> CVPixelBuffer? {
        let size = self.size
        let width = Int(size.width)
        let height = Int(size.height)

        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            return nil
        }

        UIGraphicsPushContext(context)
        defer { UIGraphicsPopContext() }

        // Рисуем изображение в контексте
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))

        return pixelBuffer
    }
}

// MARK: - Factory Methods for Different Test Scenarios
extension StaticImageCameraService {
    /// Создает мок с загруженным из Asset Catalog изображением
    static func fromAsset(named name: String, frameRate: TimeInterval = 30.0) -> StaticImageCameraService? {
        guard let image = UIImage(named: name) else {
            print("Image not found in assets: \(name)")
            return nil
        }

        return StaticImageCameraService(image: image, frameRate: frameRate)
    }

    /// Создает мок с однотонным цветом
    static func solidColor(_ color: UIColor, frameRate: TimeInterval = 30.0) -> StaticImageCameraService? {
        let size = CGSize(width: 1_920, height: 1_080)
        let renderer = UIGraphicsImageRenderer(size: size)

        let color = color.withAlphaComponent(0.33)

        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }

        return StaticImageCameraService(image: image, frameRate: frameRate)
    }

    /// Создает мок с шахматной доской для тестирования детекции границ
    static func checkerboard(frameRate: TimeInterval = 30.0) -> StaticImageCameraService? {
        let size = CGSize(width: 1_920, height: 1_080)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            UIColor.white.setFill()
            context.fill(rect)

            let squareSize: CGFloat = 100
            let colors: [UIColor] = [.black, .darkGray]

            for y in 0..<Int(ceil(size.height / squareSize)) {
                for x in 0..<Int(ceil(size.width / squareSize)) {
                    if (x + y) % 2 == 0 {
                        let squareRect = CGRect(
                            x: CGFloat(x) * squareSize,
                            y: CGFloat(y) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )
                        colors[(x + y) % 2].setFill()
                        context.fill(squareRect)
                    }
                }
            }
        }

        return StaticImageCameraService(image: image, frameRate: frameRate)
    }
}

// MARK: - Usage Examples
/*
// 1. Создание мока с дефолтным изображением (цветные полосы)
let mockCamera = StaticImageCameraService()
// или
let mockCamera = StaticImageCameraService.coloredStripes()

// 2. Создание мока с кастомным изображением из ассетов
let mockCamera = StaticImageCameraService.fromAsset(named: "test_image")

// 3. Создание мока с однотонным цветом
let mockCamera = StaticImageCameraService.solidColor(.red)

// 4. Создание мока с шахматной доской
let mockCamera = StaticImageCameraService.checkerboard()

// 5. Использование с другим фреймрейтом
let mockCamera = StaticImageCameraService(frameRate: 60.0) // 60 FPS

// Подписка на кадры (так же как с реальной камерой)
mockCamera?.framePublisher
    .sink { sampleBuffer in
        // Обработка буфера
        print("Получен мок-кадр")
    }
    .store(in: &cancellables)

// Управление зумом
mockCamera?.set(zoom: 2.0)
mockCamera?.set(focalLength: 52.0)

// Запуск/остановка
mockCamera?.start()
mockCamera?.stop()
*/
