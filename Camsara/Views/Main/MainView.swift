//
//  MainView.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import SwiftUI
import Combine




struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            HStack {
                WheelPicker(
                    config: .init(
                        steps: Array(
                            Int(viewModel.cameraService.deviceFocalLength)...Defaults.maxFocalLength
                        ),
                        mainSteps: Set(Defaults.mainFocalLengths)

                    ),
                    value: $viewModel.sliderValue
                )
                    .frame(width: geometry.size.width * 0.1)
                    .background(.yellow.opacity(0.2))

                FrameView(viewModel: viewModel.frameViewModel)
            }
        }
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}


