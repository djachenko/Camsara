//
//  DominantColorAlgorithm.swift
//  Camsara
//

import Combine
import CoreMedia
import UIKit


struct ProcessingOptions {
    /// Минимальный процент пикселей в кластере
    var minClusterPercentage: Double = 0.01

    /// Максимальное количество пикселей для анализа
    var maxPixelsToSample: Int = 2_000

    /// Количество итераций для итеративных алгоритмов
    var maxIterations: Int = 10

    /// Фильтровать серые/ненасыщенные цвета
    var filterGrayColors: Bool = true

    /// Порог насыщенности (0...1)
    var saturationThreshold: Double = 0.15

    /// Диапазон яркости для фильтрации
    var brightnessRange: ClosedRange<Double> = 0.15...0.9

    /// Использовать сглаживание между кадрами
    var smoothingFactor: Double = 0.7
}

protocol PaletteAlgorithm {
    var name: String { get }

    func extractColors(
        from pixelBuffer: CVPixelBuffer,
        maxColors: Int,
        options: ProcessingOptions
    ) -> [RGBColor]
}
