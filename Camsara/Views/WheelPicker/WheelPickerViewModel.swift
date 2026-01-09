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
    @Published var orientation: DeviceOrientation = .portrait

    init(orientationService: DeviceOrientationService) {
        orientationService.$orientation
            .assign(to: &$orientation)
    }
}

extension WheelPickerViewModel {
    static let forPreview = WheelPickerViewModel(orientationService: .init())
}
