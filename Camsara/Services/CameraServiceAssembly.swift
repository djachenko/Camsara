//
//  CameraServiceAssembly.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import AVFoundation
import DITranquillity


final class CameraServiceAssembly: DIPart {
    static func load(container: DIContainer) {
        container.register(PhysicalCameraService.init)
        container.register(MockCameraService.init)

        container.register { () -> CameraService in
            container.resolve() as PhysicalCameraService? ?? container.resolve() as MockCameraService
        }
        .lifetime(.single)

        container.register(AVCaptureSession.init)
            .lifetime(.single)
    }
}
