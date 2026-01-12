//
//  PaletteManager.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import Combine
import CoreMedia
import UIKit


final class PaletteManager {
    @Published var dominantColors: [RGBColor] = []

    private let algorithm: PaletteAlgorithm
    private let options: ProcessingOptions
    private let numberOfColors: Int
    private var cancellables = Set<AnyCancellable>()
    private var lastColors: [RGBColor] = []

    init(
        frameSource: FrameSource,
        algorithm: PaletteAlgorithm,
        options: ProcessingOptions? = nil,
        numberOfColors: Int = 4
    ) {
        self.algorithm = algorithm
        self.options = options ?? ProcessingOptions()
        self.numberOfColors = numberOfColors

        print("🎨 DominantColorAnalyzer: используется алгоритм \(algorithm.name)")

        setupPipeline(with: frameSource)
    }

    private func setupPipeline(with frameSource: FrameSource) {
        frameSource.framePublisher
            .throttle(
                for: .seconds(0.15), // Увеличили с 0.1 до 0.15 для большей стабильности
                scheduler: DispatchQueue.global(qos: .userInteractive),
                latest: true
            )
            .compactMap { [weak self] sample in
                self?.processFrame(sample)
            }
//            .map { [weak self] newColors in
//                self?.applySmoothing(newColors) ?? newColors
//            }
//            .removeDuplicates { colors1, colors2 in
//                guard colors1.count == colors2.count else { return false }
//
//                // Используем сопоставление цветов для более точного сравнения
//                // Это учитывает, что цвета могут быть в разном порядке
//                let matched = self.matchColorsForComparison(oldColors: colors1, newColors: colors2)
//                var totalDistance = 0.0
//
//                for (c1, c2) in zip(colors1, matched) {
//                    let dist = colorDistance(c1, c2)
//                    if dist >= 0.08 {
//                        return false
//                    }
//                    totalDistance += dist
//                }
//
//                // Дополнительная проверка: среднее расстояние должно быть небольшим
//                let avgDistance = totalDistance / Double(colors1.count)
//                return avgDistance < 0.06
//            }
            .assign(to: &$dominantColors)
    }

    private func processFrame(_ sample: CMSampleBuffer) -> [RGBColor]? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sample) else {
            return nil
        }

        var colors = algorithm.extractColors(
            from: pixelBuffer,
            maxColors: numberOfColors,
            options: options
        )

        // Сортируем цвета по яркости для стабильного порядка
        // Это предотвращает "прыжки" цветов при минимальных изменениях кадра
        colors.sort { color1, color2 in
            let brightness1 = color1.r * 0.299 + color1.g * 0.587 + color1.b * 0.114
            let brightness2 = color2.r * 0.299 + color2.g * 0.587 + color2.b * 0.114
            if brightness1 != brightness2 {
                return brightness1 > brightness2
            }
            // Вторичная сортировка по насыщенности для полной стабильности
            let hsb1 = HSBColor(color1)
            let hsb2 = HSBColor(color2)
            if hsb1.s != hsb2.s {
                return hsb1.s > hsb2.s
            }
            return hsb1.h < hsb2.h
        }

        // Гарантируем нужное количество цветов
        if colors.count < numberOfColors {
            var padded = colors
            let lastColor = colors.last ?? .gray

            while padded.count < numberOfColors {
                padded.append(lastColor)
            }

            return padded
        }

        return Array(colors.prefix(numberOfColors))
    }

    private func applySmoothing(_ newColors: [RGBColor]) -> [RGBColor] {
        guard !lastColors.isEmpty, lastColors.count == newColors.count else {
            lastColors = newColors
            return newColors
        }

        // Сопоставляем цвета между кадрами по близости, а не просто по индексу
        // Это предотвращает "прыжки" когда цвета меняются местами
        let matchedColors = matchColors(oldColors: lastColors, newColors: newColors)

        // Проверяем общее изменение для определения необходимости более агрессивного сглаживания
        var totalChange = 0.0
        for (old, new) in zip(lastColors, matchedColors) {
            totalChange += colorDistance(old, new)
        }
        let avgChange = totalChange / Double(lastColors.count)

        // Если изменение слишком большое, используем более агрессивное сглаживание
        let effectiveFactor = avgChange > 0.15 ? min(options.smoothingFactor + 0.1, 0.95) : options.smoothingFactor

        let smoothed = zip(lastColors, matchedColors).map { old, new in
            let r = old.r * effectiveFactor + new.r * (1 - effectiveFactor)
            let g = old.g * effectiveFactor + new.g * (1 - effectiveFactor)
            let b = old.b * effectiveFactor + new.b * (1 - effectiveFactor)

            return RGBColor(
                r: r,
                g: g,
                b: b
            )
        }

        lastColors = smoothed
        return smoothed
    }

    /// Сопоставляет новые цвета со старыми по минимальному расстоянию
    /// Это предотвращает "прыжки" когда похожие цвета меняются местами
    private func matchColors(oldColors: [RGBColor], newColors: [RGBColor]) -> [RGBColor] {
        guard oldColors.count == newColors.count else {
            return newColors
        }

        var used = Set<Int>()
        var matched = [RGBColor](repeating: .gray, count: oldColors.count)

        // Для каждого старого цвета находим ближайший новый цвет
        for (oldIndex, oldColor) in oldColors.enumerated() {
            var minDist = Double.greatestFiniteMagnitude
            var bestNewIndex = 0

            for (newIndex, newColor) in newColors.enumerated() {
                if used.contains(newIndex) { continue }

                let dist = colorDistance(oldColor, newColor)
                if dist < minDist {
                    minDist = dist
                    bestNewIndex = newIndex
                }
            }

            matched[oldIndex] = newColors[bestNewIndex]
            used.insert(bestNewIndex)
        }

        return matched
    }

    /// Вспомогательная функция для сопоставления цветов при сравнении
    /// Используется в removeDuplicates для более точного сравнения
    private func matchColorsForComparison(oldColors: [RGBColor], newColors: [RGBColor]) -> [RGBColor] {
        return matchColors(oldColors: oldColors, newColors: newColors)
    }
}

// MARK: - Поддержка ColorsSource
extension PaletteManager: ColorsSource {
    var colors: AnyPublisher<[RGBColor], Never> {
        $dominantColors.eraseToAnyPublisher()
    }
}

// MARK: - Удобные конструкторы
extension PaletteManager {
    static func createKMeansAnalyzer(
        frameSource: FrameSource,
        numberOfColors: Int = 4
    ) -> PaletteManager {
        let algorithm = KMeansPlusPlusLabAlgorithm()
        let options = ProcessingOptions(
            minClusterPercentage: 0.02,
            maxPixelsToSample: 2_000,
            maxIterations: 8,
            saturationThreshold: 0.2,
            smoothingFactor: 0.85 // Увеличили для более плавного сглаживания
        )

        return PaletteManager(
            frameSource: frameSource,
            algorithm: algorithm,
            options: options,
            numberOfColors: numberOfColors
        )
    }

    static func createMedianCutAnalyzer(
        frameSource: FrameSource,
        numberOfColors: Int = 4
    ) -> PaletteManager {
        let algorithm = MedianCutAlgorithm()
        let options = ProcessingOptions(
            minClusterPercentage: 0.01,
            maxPixelsToSample: 3_000,
            maxIterations: 1,
            smoothingFactor: 0.9 // Увеличили для более плавного сглаживания
        )

        return PaletteManager(
            frameSource: frameSource,
            algorithm: algorithm,
            options: options,
            numberOfColors: numberOfColors
        )
    }

    static func createOctreeAnalyzer(
        frameSource: FrameSource,
        numberOfColors: Int = 4
    ) -> PaletteManager {
        let algorithm = OctreeQuantizationAlgorithm()
        let options = ProcessingOptions(
            minClusterPercentage: 0.005,
            maxPixelsToSample: 5_000,
            smoothingFactor: 0.9
        )

        return PaletteManager(
            frameSource: frameSource,
            algorithm: algorithm,
            options: options,
            numberOfColors: numberOfColors
        )
    }
}

private func colorDistance(_ a: RGBColor, _ b: RGBColor) -> Double {
    sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2))
}
