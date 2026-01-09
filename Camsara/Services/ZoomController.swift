//
//  ZoomController.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import UIKit


struct ZoomState {
    let frameScale: Double
    let previewScale: Double
    let cameraScale: Double
}

final class ZoomController {
    private enum Constants {
        static let frame2cameraFocalThreshold = 2.0
    }

    private let cameraFocalLength: Double
    private let cameraRatio: Double

    private var maxPreviewScale = 1.0

    init(cameraFocalLength: Double, cameraRatio: Double) {
        self.cameraFocalLength = cameraFocalLength
        self.cameraRatio = cameraRatio
    }
}

extension ZoomController {
    func set(focalLength: Int) -> ZoomState {
        let focalRatio = Double(focalLength) / cameraFocalLength

        return ZoomState(
            frameScale: countFrameScale(focalRatio: focalRatio),
            previewScale: countPreviewScale(focalRatio: focalRatio),
            cameraScale: countCameraScale(focalRatio: focalRatio)
        )
    }

    func set(cameraSize size: CGSize) {
        let minCameraWidth = size.height * cameraRatio
        let maxCameraWidth = size.width

        maxPreviewScale = max(1, maxCameraWidth / minCameraWidth)
    }
}

private extension ZoomController {
    func countFrameScale(focalRatio: Double) -> Double {
        1 / min(focalRatio, Constants.frame2cameraFocalThreshold)
    }

    func countPreviewScale(focalRatio: Double) -> Double {
        (1...maxPreviewScale).clamp(focalRatio / Constants.frame2cameraFocalThreshold)
    }

    func countCameraScale(focalRatio: Double) -> Double {
        max(1, focalRatio / Constants.frame2cameraFocalThreshold / maxPreviewScale)
    }
}
