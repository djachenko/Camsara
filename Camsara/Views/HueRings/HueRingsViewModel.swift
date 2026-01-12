//
//  HueRingsViewModel.swift
//  Camsara
//
//  Created by justin on 11/1/26.
//

import Foundation

final class HueRingsViewModel {
    let colorProviders: [ColorsSource]

    init(colorProviders: [ColorsSource]) {
        self.colorProviders = colorProviders
    }
}

extension HueRingsViewModel {
    static let forPreview = HueRingsViewModel(colorProviders: [])
}
