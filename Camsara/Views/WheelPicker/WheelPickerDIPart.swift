//
//  WheelPickerDIPart.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import DITranquillity

final class WheelPickerDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register(WheelPickerViewModel.init)
    }
}
