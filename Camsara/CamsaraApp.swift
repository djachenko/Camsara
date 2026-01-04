//
//  CamsaraApp.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import Combine
import DITranquillity
import SwiftUI


@main
struct CamsaraApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: CamsaraDI.container.resolve()
            )
        }
    }
}
