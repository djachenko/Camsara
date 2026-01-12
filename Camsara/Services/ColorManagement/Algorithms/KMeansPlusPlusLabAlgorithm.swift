//
//  KMeansPlusPlusLabAlgorithm.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import CoreVideo


// MARK: - 1. K-means++ в LAB пространстве
final class KMeansPlusPlusLabAlgorithm: PaletteAlgorithm {
    let name = "K-means++ (LAB)"

    func extractColors(
        from pixelBuffer: CVPixelBuffer,
        maxColors: Int,
        options: ProcessingOptions
    ) -> [RGBColor] {
        let pixels = pixelBuffer.downsamplePixelBuffer(maxPixelsToSample: options.maxPixelsToSample)

        guard !pixels.isEmpty else {
            return []
        }

        let labPixels = pixels.map { LABColor($0) }
        let k = min(maxColors, labPixels.count)

        var centroids = kMeansPlusPlusInitialize(labPixels, k: k)
        var assignments = [Int](repeating: -1, count: labPixels.count)

        for _ in 0..<options.maxIterations {
            // Привязка точек к центроидам
            for (i, pixel) in labPixels.enumerated() {
                var minDist = Double.greatestFiniteMagnitude
                var bestIdx = 0

                for (j, centroid) in centroids.enumerated() {
                    let dist = LABColor.distance(between: pixel, and: centroid)

                    if dist < minDist {
                        minDist = dist
                        bestIdx = j
                    }
                }

                assignments[i] = bestIdx
            }

            // Пересчет центроидов с фильтрацией
            var newCentroids: [LABColor] = []
            var clusterSizes = [Int](repeating: 0, count: centroids.count)

            for assignment in assignments {
                clusterSizes[assignment] += 1
            }

            for i in 0..<centroids.count {
                let size = clusterSizes[i]
                if Double(size) / Double(labPixels.count) >= options.minClusterPercentage {
                    let clusterPoints = labPixels.enumerated()
                        .filter { $0.offset < assignments.count && assignments[$0.offset] == i }
                        .map { $0.element }

                    if !clusterPoints.isEmpty {
                        newCentroids.append(LABColor.average(colors: clusterPoints))
                    }
                }
            }

            if newCentroids.count == centroids.count {
                var changed = false

                for i in 0..<centroids.count {
                    if LABColor.distance(between: centroids[i], and: newCentroids[i]) > 0.1 {
                        changed = true

                        break
                    }
                }

                if !changed {
                    break
                }
            }

            centroids = newCentroids

            if centroids.isEmpty {
                break
            }
        }

        return centroids.map { RGBColor($0) }
    }
}

private func kMeansPlusPlusInitialize(_ points: [LABColor], k: Int) -> [LABColor] {
    guard !points.isEmpty, k > 0 else { return [] }

    var centroids: [LABColor] = []

    // Первый центроид - детерминированный (первый пиксель для стабильности)
    // Используем медианный пиксель по яркости для лучшей стабильности
    let sortedByL = points.sorted { $0.l < $1.l }
    let medianIndex = sortedByL.count / 2
    centroids.append(sortedByL[medianIndex])

    for _ in 1..<min(k, points.count) {
        var distances: [Double] = []
        var totalDistance: Double = 0

        for point in points {
            var minDist = Double.greatestFiniteMagnitude
            for centroid in centroids {
                let dist = LABColor.distance(between: point, and: centroid)
                minDist = min(minDist, dist)
            }
            distances.append(minDist)
            totalDistance += minDist
        }

        // Выбираем следующий центроид детерминированно (максимальное расстояние)
        // Это более стабильно, чем случайный выбор
        // Используем сортировку с вторичными ключами для полной детерминированности
        let candidates = distances.enumerated().map { (index: $0.offset, dist: $0.element, l: points[$0.offset].l) }
        let best = candidates.max { c1, c2 in
            if abs(c1.dist - c2.dist) > 0.001 {
                return c1.dist < c2.dist
            }
            // При одинаковом расстоянии выбираем по яркости
            return c1.l > c2.l
        }

        if let best = best {
            centroids.append(points[best.index])
        }
    }

    return centroids
}
