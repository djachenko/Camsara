//
//  ServiceAssembly.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import AVFoundation
import DITranquillity


final class ServiceAssembly: DIPart {
    static func load(container: DIContainer) {

        switch Environment.current {
        case .device:
            container.register(PhysicalCameraService.init)
                .postInit { $0?.start() }
                .as(CameraService.self)
                .lifetime(.single)
        case .simulator:
            container.register(MockCameraService.init)
                .as(CameraService.self)
                .lifetime(.single)
        }

        container.register(AVCaptureSession.init)
            .lifetime(.single)

        container.register(DeviceOrientationService.init)
            .lifetime(.perContainer(.weak))
    }
}
