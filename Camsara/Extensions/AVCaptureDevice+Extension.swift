//
//  AVCaptureDevice+Extension.swift
//  Camsara
//
//  Created by justin on 23.12.2025.
//

import AVFoundation

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
