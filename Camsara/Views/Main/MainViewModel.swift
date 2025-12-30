//
//  MainViewModel.swift
//  Camsara
//
//  Created by justin on 22.12.2025.
//

import Combine
import AVFoundation


final class MainViewModel: ObservableObject {
    private enum Constants {
        static let threshold = 0.5
    }

    @Published var sliderValue = 0

    let frameViewModel: FrameViewModel
    let cameraService: CameraService

    private var cancellables = Set<AnyCancellable>()

    init(cameraService: CameraService, frameViewModel: FrameViewModel) {
        self.cameraService = cameraService
        self.frameViewModel = frameViewModel

        sliderValue = Int(cameraService.deviceFocalLength)

        $sliderValue.sink { [weak self] sliderFocal in
            guard let self,
                sliderFocal != 0 else {
                return
            }

            let sliderFocal = Double(sliderFocal)
            let focalLength = cameraService.deviceFocalLength

            let frameScale = (Constants.threshold...1).clamp(focalLength / sliderFocal)
            let frameZoom = max(sliderFocal / cameraService.deviceFocalLength * Constants.threshold, 1)

            self.frameViewModel.scaleFactor = frameScale
            self.cameraService.set(zoom: frameZoom)
        }.store(in: &cancellables)
    }
}

extension MainViewModel {
    static let forPreview = MainViewModel(
        cameraService: MockCameraService(),
        frameViewModel: .forPreview
    )
}
