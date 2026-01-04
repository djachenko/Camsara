//
//  CameraService.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import AVFoundation


protocol CameraService {
    var session: AVCaptureSession { get }

    var deviceFocalLength: Double { get }
    var w2hRatio: Double { get }

    func set(zoom: Double)
}
