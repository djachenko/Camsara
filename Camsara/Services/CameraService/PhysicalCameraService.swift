//
//  PhysicalCameraService.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import AVFoundation


final class PhysicalCameraService {
    let session: AVCaptureSession

    var w2hRatio: Double {
        let dimensions = camera.activeFormat.formatDescription.dimensions

        return Double(dimensions.width) / Double(dimensions.height)
    }

    private let sessionQueue = DispatchQueue(label: "com.raywenderlich.SessionQ")
    private let camera: AVCaptureDevice

    init?(session: AVCaptureSession) {
        guard let camera = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera,
            ],
            mediaType: .video,
            position: .back
        ).devices.first else {
            return nil
        }

        self.session = session
        self.camera = camera

        configure()
    }
}

extension PhysicalCameraService: CameraService {
    var deviceFocalLength: Double {
        if #available(iOS 26.0, *) {
            Double(camera.nominalFocalLengthIn35mmFilm)
        } else {
            camera.get35mmEquivalentFocalLength()
        }
        // iPhone 13
        // builtInDualWideCamera camera: focal 13.5738718906176 mm, zoom 1.0-189.0
        // builtInWideAngleCamera camera: focal 26.78571488320383 mm, zoom 1.0-189.0
        // builtInUltraWideCamera camera: focal 13.5738718906176 mm, zoom 1.0-189.0
    }

    var currentFocalLength: Double {
        camera.videoZoomFactor * deviceFocalLength
    }

    func set(zoom: Double) {
        try? camera.lockForConfiguration()
        defer { camera.unlockForConfiguration() }

        if camera.isRampingVideoZoom {
            camera.cancelVideoZoomRamp()
        }

        camera.ramp(toVideoZoomFactor: zoom, withRate: 3.0)
    }

    func set(focalLength: Double) {
        set(zoom: focalLength / deviceFocalLength)
    }
}

extension PhysicalCameraService {
    func set( delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue ) {
        //    videoOutput.setSampleBufferDelegate(delegate, queue: queue)
    }
}

private extension PhysicalCameraService {
    func checkPermissions() {
        switch AVCaptureDevice
            .authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        default:
            break
        }
    }

    func configure() {
        checkPermissions()
        configureCaptureSession()

        start()
    }

    func configureCaptureSession() {
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }

        try? session.addInput(AVCaptureDeviceInput(device: camera))
        session.sessionPreset = .photo
    }

    func start() {
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    func end() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
}
