//
//  OrientationParameters.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import UIKit


struct OrientationParameters {
    let angle: Double
    let offsetX: Double
    let offsetY: Double

    let transform: CGAffineTransform

    static let portrait = OrientationParameters(
        angle: 90,
        offsetX: 0,
        offsetY: -20
    )

    static let landscapeLeft = OrientationParameters(
        angle: 180,
        offsetX: -20,
        offsetY: 0
    )

    static let landscapeRight = OrientationParameters(
        angle: 0,
        offsetX: 20,
        offsetY: 0
    )

    static let portraitUpsideDown = OrientationParameters(
        angle: 270,
        offsetX: 0,
        offsetY: 20
    )

    static let unknown = OrientationParameters(
        angle: 0,
        offsetX: 0,
        offsetY: 0
    )

    private init(angle: Double, offsetX: Double, offsetY: Double) {
        self.angle = angle
        self.offsetX = offsetX
        self.offsetY = offsetY

        transform = .identity
            .rotated(by: angle * .pi / 180.0)
    }

    static func parameters(for orientation: DeviceOrientationService.Orientation) -> Self {
        switch orientation {
        case .portrait:
                .portrait
        case .landscapeLeft:
                .landscapeLeft
        case .landscapeRight:
                .landscapeRight
        case .portraitUpsideDown:
                .portraitUpsideDown
        case .unknown:
                .unknown
        }
    }
}
