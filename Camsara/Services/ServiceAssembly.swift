//
//  ServiceAssembly.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import AVFoundation
import DITranquillity
import UIKit


final class ServiceAssembly: DIPart {
    static func load(container: DIContainer) {
        switch Environment.current {
        case .device:
            container.register(PhysicalCameraService.init)
                .as(CameraService.self)
                .as(FrameSource.self)
                .postInit { $0?.start() }
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

//        container.register { ColorSchemePipeline(frameSource: $0, numberOfColors: 3) }
//            .as(ColorsSource.self)
//            .lifetime(.single)

//        container.register { PaletteManager.createKMeansAnalyzer(frameSource: $0, numberOfColors: 1) }
//            .as(ColorsSource.self)
//            .lifetime(.single)
////            .default()
//
//        container.register { PaletteManager.createMedianCutAnalyzer(frameSource: $0, numberOfColors: 1) }
//            .as(ColorsSource.self)
//            .lifetime(.single)
//            .default()
//
//        container.register { PaletteManager.createOctreeAnalyzer(frameSource: $0, numberOfColors: 1) }
//            .as(ColorsSource.self)
//            .lifetime(.single)
//            .default()

        container.register { PaletteManager(frameSource: $0, algorithm: DumbAverageAlgorithm(), numberOfColors: 1) }
            .as(ColorsSource.self)
            .lifetime(.single)
//            .default()

        container.register { StaticImageCameraService(image: .init(resource: .orange), frameRate: 20)}
//        container.register { StaticImageCameraService.solidColor(.green) }
//            .as(FrameSource.self)
            .lifetime(.single)

        container.register { SolidColorFrameSource(color: .blue) }
//            .as(FrameSource.self)
            .lifetime(.single)
    }
}
