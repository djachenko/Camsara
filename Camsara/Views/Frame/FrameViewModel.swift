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

    @Published var frameScale: Double = 1
    @Published var previewScale: Double = 1

    @Published var size: CGSize = .zero

    init(
        session: AVCaptureSession
    ) {
        self.session = session
    }

    func update(size: CGSize) {
        self.size = size
    }
}

extension FrameViewModel {
    static let forPreview = FrameViewModel(session: .init())
}
