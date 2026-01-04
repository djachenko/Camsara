//
//  CamsaraApp.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import Combine
import SwiftUI

@main
struct CamsaraApp: App {
    private let cameraService = PhysicalCameraService()
//    private let cameraService: CameraService? = MockCameraService()

    var body: some Scene {
        WindowGroup {
            if let cameraService {
                MainView(
                    viewModel: .init(
                        cameraService: cameraService,
                        frameViewModel: FrameViewModel(session: cameraService.session)
                    )
                )
            } else {
                Text("No camera available")
            }
        }
    }
}
