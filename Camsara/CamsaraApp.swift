//
//  CamsaraApp.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import SwiftUI
import Combine

@main
struct CamsaraApp: App {
    private let viewModel = ContentViewModel()
    private let cameraManager = CameraManager()

    var body: some Scene {
        WindowGroup {
            CameraPreviewViewHolder(session: cameraManager.session)
        }
    }
}
