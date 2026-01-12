//
//  HueRingsDIPart.swift
//  Camsara
//
//  Created by justin on 11/1/26.
//

import DITranquillity

final class HueRingsDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register { HueRingsViewModel(colorProviders: many($0))}
    }
}
