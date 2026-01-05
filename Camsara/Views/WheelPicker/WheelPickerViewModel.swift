//
//  WheelPickerViewModel.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import Combine
import Foundation


final class WheelPickerViewModel: ObservableObject {
    @Published var pickerValue: Int = 0
    @Published var orientation: DeviceOrientationService.Orientation = .portrait

    private var cancellables = Set<AnyCancellable>()

    init(orientationService: DeviceOrientationService) {
        orientationService.$orientation.sink { [weak self] in
            self?.orientation = $0
        }.store(in: &cancellables)
    }
}

extension WheelPickerViewModel {
    static let forPreview = WheelPickerViewModel(orientationService: .init())
}
