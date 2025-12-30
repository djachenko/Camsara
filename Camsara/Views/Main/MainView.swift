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
        let config = WheelPicker.Config(
            steps: Array(
                Int(viewModel.cameraService.deviceFocalLength)...Defaults.maxFocalLength
            ),
            mainSteps: Set(Defaults.mainFocalLengths)
        )

        GeometryReader { geometry in
            HStack {
                WheelPicker(
                    config: config,
                    value: $viewModel.sliderValue
                )
                .frame(width: geometry.size.width * 0.1)
                .background(.yellow.opacity(0.2))

                WheelPickerUIViewHolder(
                    config: config,
                    uiConfig: .init(),
                    verticalInset: geometry.size.height / 2
                )
                .frame(width: geometry.size.width * 0.1)
                .background(.green.opacity(0.2))

                FrameView(viewModel: viewModel.frameViewModel)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}


