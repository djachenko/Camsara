//
//  MainViewModel.swift
//  Camsara
//
//  Created by justin on 22.12.2025.
//

import AVFoundation
import Combine
import UIKit

protocol ColorsSource {
    var colors: AnyPublisher<[RGBColor], Never> { get }
}

final class MockColorsSource: ColorsSource {
    var colors: AnyPublisher<[RGBColor], Never> {
        Just([.red, .green, .blue])
            .eraseToAnyPublisher()
    }
}

final class MainViewModel: ObservableObject {
    @Published var colors: [HueMarker] = []

    let frameViewModel: FrameViewModel
    let pickerViewModel: WheelPickerViewModel
    let hueRingsViewModel: HueRingsViewModel

    let cameraService: CameraService
    let zoomController: ZoomController

    private var cancellables = Set<AnyCancellable>()

    private var maxPreviewScale = 1.0

    init(
        cameraService: CameraService,
        frameViewModel: FrameViewModel,
        pickerViewModel: WheelPickerViewModel,
        hueRingsViewModel: HueRingsViewModel
    ) {
        self.cameraService = cameraService
        self.frameViewModel = frameViewModel
        self.pickerViewModel = pickerViewModel
        self.hueRingsViewModel = hueRingsViewModel

        self.zoomController = ZoomController(
            cameraFocalLength: cameraService.deviceFocalLength,
            cameraRatio: cameraService.w2hRatio
        )

        pickerViewModel.pickerValue = Int(cameraService.deviceFocalLength)

        pickerViewModel.$pickerValue
            .removeDuplicates()
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] in
                guard let self else {
                    return
                }

                let zooms = self.zoomController.set(focalLength: $0)

                self.frameViewModel.frameScale = zooms.frameScale
                self.frameViewModel.previewScale = zooms.previewScale

                self.cameraService.set(zoom: zooms.cameraScale)
            }
            .store(in: &cancellables)


        frameViewModel.$size.sink { [weak self] size in
            self?.zoomController.set(cameraSize: size)
        }.store(in: &cancellables)
//
//        colorsProvider.colors
//            .map { $0.map { HueMarker($0) }}
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$colors)
    }
}

extension MainViewModel {
    static let forPreview = MainViewModel(
        cameraService: MockCameraService.forPreview,
        frameViewModel: .forPreview,
        pickerViewModel: .forPreview,
        hueRingsViewModel: .forPreview
    )
}
