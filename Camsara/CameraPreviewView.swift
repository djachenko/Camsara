//
//  CameraPreviewView.swift
//  Camsara
//
//  Created by justin on 12.12.2025.
//

import AVFoundation
import SwiftUI
import UIKit

final class CameraPreviewView: UIView {
    private var captureSession: AVCaptureSession

    init(session: AVCaptureSession) {
        self.captureSession = session

        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override static var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Layer must be AVCaptureVideoPreviewLayer")
        }

        return layer
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil {
            videoPreviewLayer.session = captureSession
            videoPreviewLayer.videoGravity = .resizeAspect

            videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            videoPreviewLayer.connection?.automaticallyAdjustsVideoMirroring = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        videoPreviewLayer.frame = bounds
    }
}

struct CameraPreviewViewHolder: UIViewRepresentable {
    let session: AVCaptureSession

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    func makeUIView(context: Context) -> UIView {
        CameraPreviewView(session: session)
    }
}
