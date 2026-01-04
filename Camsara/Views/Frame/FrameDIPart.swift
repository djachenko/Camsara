//
//  FrameDIPart.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import DITranquillity

final class FrameDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register(FrameViewModel.init)
    }
}
