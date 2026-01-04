//
//  FrameViewModel.swift
//  Camsara
//
//  Created by justin on 22.12.2025.
//

import AVFoundation
import Combine

final class FrameViewModel: ObservableObject {
    let session: AVCaptureSession

    @Published var frameScale: Double
    @Published var previewScale: Double

    @Published var size: CGSize = .zero

    init(
        session: AVCaptureSession,
        scaleFactor: Double = 1.0,
        previewScale: Double = 1.0,
    ) {
        self.session = session
        self.frameScale = scaleFactor
        self.previewScale = previewScale
    }
}

extension FrameViewModel {
    static let forPreview = FrameViewModel(session: .init())
}
