//
//  OctreeQuantizationAlgorithm.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import UIKit

// MARK: - OctreeNode
private class OctreeNode {
    var isLeaf: Bool = false
    var pixelCount: Int = 0
    var redSum: Int = 0
    var greenSum: Int = 0
    var blueSum: Int = 0
    var children: [OctreeNode?] = Array(repeating: nil, count: 8)

    var averageColor: (r: UInt8, g: UInt8, b: UInt8) {
        guard pixelCount > 0 else {
            return (0, 0, 0)
        }

        return (
            r: UInt8(redSum / pixelCount),
            g: UInt8(greenSum / pixelCount),
            b: UInt8(blueSum / pixelCount)
        )
    }

    func addColor(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ level: Int, _ reducibleNodes: inout [[OctreeNode]]) {
        if isLeaf {
            pixelCount += 1
            redSum += Int(r)
            greenSum += Int(g)
            blueSum += Int(b)
        } else {
            let shift = 7 - level

            let rBit = (Int(r) >> shift) & 1
            let gBit = (Int(g) >> shift) & 1
            let bBit = (Int(b) >> shift) & 1
            let index = (rBit << 2) | (gBit << 1) | bBit

            if children[index] == nil {
                children[index] = OctreeNode()

                if level == 7 {
                    children[index]!.isLeaf = true
                } else {
                    reducibleNodes[level].append(children[index]!)
                }
            }

            children[index]!.addColor(r, g, b, level + 1, &reducibleNodes)
        }
    }

    func collectLeaves(_ leaves: inout [OctreeNode]) {
        if isLeaf {
            leaves.append(self)
        } else {
            for child in children.compactMap({ $0 }) {
                child.collectLeaves(&leaves)
            }
        }
    }
}

// MARK: - Octree Quantization (очень быстрый)
private class Octree {
    private let maxLeaves: Int
    private var root: OctreeNode
    private var leafCount: Int = 0
    private var reducibleNodes: [[OctreeNode]]

    init(maxLeaves: Int) {
        self.maxLeaves = maxLeaves
        self.root = OctreeNode()
        self.reducibleNodes = Array(repeating: [], count: 8)
    }

    func insert(color: (r: UInt8, g: UInt8, b: UInt8)) {
        root.addColor(color.r, color.g, color.b, 0, &reducibleNodes)
        leafCount += 1

        // Сокращаем дерево, если превышено максимальное количество листьев
        while leafCount > maxLeaves {
            guard let nodeToReduce = findReducibleNode() else { break }
            reduceNode(nodeToReduce)
        }
    }

    private func findReducibleNode() -> OctreeNode? {
        // Ищем самый глубокий уровень с reducible nodes
        // Используем первый узел вместо последнего для большей стабильности
        // и сортируем по количеству пикселей для предсказуемости
        for level in (0..<8).reversed() {
            if !reducibleNodes[level].isEmpty {
                // Выбираем узел с наименьшим количеством пикселей для более стабильного результата
                return reducibleNodes[level].min { $0.pixelCount < $1.pixelCount } ?? reducibleNodes[level].first
            }
        }
        return nil
    }

    private func reduceNode(_ node: OctreeNode) {
        // Находим и удаляем узел из reducibleNodes
        for level in 0..<8 {
            if let index = reducibleNodes[level].firstIndex(where: { $0 === node }) {
                reducibleNodes[level].remove(at: index)
                break
            }
        }

        // Объединяем детей в текущий узел
        var redSum = 0
        var greenSum = 0
        var blueSum = 0
        var pixelCount = 0

        for child in node.children.compactMap({ $0 }) {
            redSum += child.redSum
            greenSum += child.greenSum
            blueSum += child.blueSum
            pixelCount += child.pixelCount
        }

        node.isLeaf = true
        node.redSum = redSum
        node.greenSum = greenSum
        node.blueSum = blueSum
        node.pixelCount = pixelCount
        node.children = Array(repeating: nil, count: 8)

        leafCount -= (8 - 1) // Уменьшаем количество листьев (объединили 8 в 1)
    }

    func getPalette() -> [(r: UInt8, g: UInt8, b: UInt8)] {
        var leaves: [OctreeNode] = []
        root.collectLeaves(&leaves)

        // Сортируем по частоте встречаемости
        leaves.sort { $0.pixelCount > $1.pixelCount }

        // Возвращаем цвета, ограничивая максимальным количеством
        return leaves.prefix(maxLeaves).map { $0.averageColor }
    }
}

extension RGBColor {
    init(rgb: (r: UInt8, g: UInt8, b: UInt8)) {
        self.init(
            r: Double(rgb.r) / 255.0,
            g: Double(rgb.g) / 255.0,
            b: Double(rgb.b) / 255.0,
        )
    }
}


// MARK: - Алгоритм квантования октодеревом
final class OctreeQuantizationAlgorithm: PaletteAlgorithm {
    let name = "Octree Quantization"

    func extractColors(
        from pixelBuffer: CVPixelBuffer,
        maxColors: Int,
        options: ProcessingOptions
    ) -> [RGBColor] {
        // Даунсэмплинг для ускорения обработки
        let pixels = pixelBuffer.downsamplePixelBuffer(maxPixelsToSample: options.maxPixelsToSample)
        let octree = Octree(maxLeaves: maxColors)

        // Добавляем все пиксели в октодерево
        for pixel in pixels {
            let rInt = UInt8(pixel.r * 255)
            let gInt = UInt8(pixel.g * 255)
            let bInt = UInt8(pixel.b * 255)

            octree.insert(color: (r: rInt, g: gInt, b: bInt))
        }

        // Получаем палитру и конвертируем в RGBColor
        return octree.getPalette().map { RGBColor(rgb: $0) }
    }
}
