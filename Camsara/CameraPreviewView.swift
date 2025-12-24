//
//  CameraPreviewView.swift
//  Camsara
//
//  Created by justin on 12.12.2025.
//

import UIKit
import AVFoundation
import SwiftUI

final class CameraPreviewView: UIView {
    private var captureSession: AVCaptureSession

    init(session: AVCaptureSession) {
        self.captureSession = session

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if nil != self.superview {
            videoPreviewLayer.session = captureSession
            videoPreviewLayer.videoGravity = .resizeAspect
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoPreviewLayer.frame = bounds
    }
}

//extension CameraPreviewView: UIViewRepresentable {
//    func updateUIView(_ uiView: UIViewType, context: Context) {}
//    
//    func makeUIView(context: Context) -> some UIView {
//        self
//    }
//}

struct CameraPreviewViewHolder : UIViewRepresentable {
    let session: AVCaptureSession

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    func makeUIView(context: Context) -> UIView {
        CameraPreviewView(session: session)
    }
}
