//
//  MockCameraService.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import AVFoundation


final class MockCameraService: CameraService {
    var w2hRatio: Double = 4.0 / 3.0

    var deviceFocalLength = 24.0

    func set(zoom: Double) {}

    let session: AVCaptureSession

    init(session: AVCaptureSession) {
        self.session = session
    }
}

extension MockCameraService {
    static let forPreview = MockCameraService(session: .init())
}
