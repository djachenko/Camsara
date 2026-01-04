//
//  MainViewModel.swift
//  Camsara
//
//  Created by justin on 22.12.2025.
//

import AVFoundation
import Combine


final class MainViewModel: ObservableObject {
    private enum Constants {
        static let threshold = 2.0
    }

    @Published var sliderValue = 0
    @Published private var focalRatio = 1.0

    let frameViewModel: FrameViewModel
    let cameraService: CameraService

    private var cancellables = Set<AnyCancellable>()

    private var maxPreviewScale = 1.0

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
            let cameraFocal = cameraService.deviceFocalLength

            focalRatio = sliderFocal / cameraFocal
        }.store(in: &cancellables)

        $focalRatio.sink { [weak self] focalRatio in
            self?.frameViewModel.frameScale = 1 / min(focalRatio, Constants.threshold)
        }.store(in: &cancellables)

        $focalRatio.sink { [weak self] focalRatio in
            guard let self else {
                return
            }

            let scale = focalRatio / Constants.threshold

            frameViewModel.previewScale = (1...maxPreviewScale).clamp(scale)
        }.store(in: &cancellables)

        $focalRatio.sink { [weak self] focalRatio in
            guard let self else {
                return
            }

            let scale = focalRatio / Constants.threshold / maxPreviewScale

            cameraService.set(zoom: max(1, scale))
        }.store(in: &cancellables)

        frameViewModel.$size.sink { [weak self] size in
            guard let self else {
                return
            }

            let minCameraWidth = size.height * cameraService.w2hRatio
            let maxCameraWidth = size.width

            maxPreviewScale = max(1, maxCameraWidth / minCameraWidth)
        }.store(in: &cancellables)
    }
}

extension MainViewModel {
    static let forPreview = MainViewModel(
        cameraService: MockCameraService.forPreview,
        frameViewModel: .forPreview
    )
}
