//
//  FrameViewModel.swift
//  Camsara
//
//  Created by justin on 22.12.2025.
//

import Combine
import AVFoundation

final class FrameViewModel: ObservableObject {
    let session: AVCaptureSession

    @Published var scaleFactor: Double

    init(
        session: AVCaptureSession,
        scaleFactor: Double = 1.0,
    ) {
        self.session = session
        self.scaleFactor = scaleFactor
    }
}

extension FrameViewModel {
    static let forPreview = FrameViewModel(session: .init())
}
