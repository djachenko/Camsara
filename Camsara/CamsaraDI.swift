//
//  CamsaraDI.swift
//  Camsara
//
//  Created by justin on 5/1/26.
//

import DITranquillity


final class CamsaraDI {
    static let container = {
        DISetting.Log.level = .info

        let container = DIContainer()
        container.append(part: ServiceAssembly.self)
        container.append(part: MainDIPart.self)
        container.append(part: FrameDIPart.self)
        container.append(part: WheelPickerDIPart.self)

        container.initializeSingletonObjects()

        if !container.makeGraph().checkIsValid(checkGraphCycles: true) {
            assertionFailure("Failed to build valid dependency graph")
        }

        return container
    }()
}
