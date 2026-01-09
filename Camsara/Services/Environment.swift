//
//  Environment.swift
//  Camsara
//
//  Created by justin on 10/1/26.
//


enum Environment {
    case simulator
    case device

    static var current: Environment {
#if targetEnvironment(simulator)
        .simulator
#else
        .device
#endif
    }
}
