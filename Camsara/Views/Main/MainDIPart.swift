//
//  MainDIPart.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import DITranquillity

final class MainDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register(MainViewModel.init)
    }
}
