////
////  HueRingView.swift
////  Camsara
////
////  Created by justin on 6/1/26.
////

import Combine
import SwiftUI

struct HueRingView: View {
    @ObservedObject var viewModel: HueRingViewModel

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2

            ZStack {
                hueRing
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90)) // 🔄 Выравниваем 0° в 3 часа

                ForEach(viewModel.markers) { marker in
                    markerView(for: marker, radius: radius)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var hueRing: some View {
        Circle()
            .strokeBorder(
                AngularGradient(
                    gradient: HueRingView.gradient,
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                lineWidth: 12
            )
    }

    private func markerView(for marker: HueMarker, radius: CGFloat) -> some View {
        // 🔧 Используем marker.hue напрямую (предполагаем диапазон 0.0...1.0)
        // Если hue в градусах (0-360), нужно делить на 360
        let hueValue = marker.hue / 360.0 // или marker.hue / 360.0 если в градусах
        let angle = Angle.degrees(360.0 * hueValue) - .degrees(90) // Вычитаем 90° для корректировки системы координат

        let x = cos(angle.radians) * radius
        let y = sin(angle.radians) * radius

        return Circle()
            .fill(Color(hue: hueValue, saturation: 1, brightness: 1))
            .frame(width: 18, height: 18)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 2)
            .offset(x: x, y: y)
            .accessibilityLabel("Цветовой маркер \(Int(hueValue * 360))°")
    }

    private static let gradient = Gradient(
        colors: stride(from: 0.0, through: 1.0, by: 0.01).map {
            Color(hue: $0, saturation: 1, brightness: 1)
        }
    )
}

// MARK: - Вспомогательная структура для отладки
#Preview("С маркерами") {
    HueRingView(viewModel: PreviewHueRingViewModel())
}

class PreviewHueRingViewModel: HueRingViewModel {
    init() {
        super.init(colorsSource: MockColorsSource())
        // Тестовые маркеры на основных цветах
        self.markers = [
            HueMarker(hue: 0.0),    // Красный
            HueMarker(hue: 0.333),  // Зеленый (~120°)
            HueMarker(hue: 0.667),  // Синий (~240°)
            HueMarker(hue: 0.167),  // Желтый (~60°)
            HueMarker(hue: 0.833),   // Пурпурный (~300°)
            HueMarker(hue: 0.5),
        ]
    }
}
