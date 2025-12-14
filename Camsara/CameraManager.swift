//
//  CameraManager.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//
import Foundation
import AVFoundation

class CameraManager {
    let session = AVCaptureSession()
    // private let sessionQueue = DispatchQueue(label: "com.raywenderlich.SessionQ")

    init() {
        configure()
    }
}

extension CameraManager {
    func set( delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue ) {
        //    videoOutput.setSampleBufferDelegate(delegate, queue: queue)
    }
}

private extension CameraManager {
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
        session.startRunning()
    }

    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        print("camera: focal \(camera.get35mmEquivalentFocalLength()) mm, zoom \(camera.minAvailableVideoZoomFactor)-\(camera.maxAvailableVideoZoomFactor)")
        // iPhone 13
        // builtInDualWideCamera camera: focal 13.5738718906176 mm, zoom 1.0-189.0
        // builtInWideAngleCamera camera: focal 26.78571488320383 mm, zoom 1.0-189.0
        // builtInUltraWideCamera camera: focal 13.5738718906176 mm, zoom 1.0-189.0

        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }

        try? session.addInput(AVCaptureDeviceInput(device: camera))
        session.sessionPreset = .photo

    }
}

extension AVCaptureDevice {
    func get35mmEquivalentFocalLength() -> Double {
        // Documentation states videoFieldOfView is the horizontal field of view in degrees
        let fov = Double(activeFormat.geometricDistortionCorrectedVideoFieldOfView)
        // Convert to radians fov *= .pi / 180.0
        // The half-width of 35mm film is 18mm. Use trigonometry to calculate the focal length.
        // focal length = half_film_width / tan(half_fov)

        let focalLen = 18 / tan(fov / 2)
        return focalLen
    }
}
