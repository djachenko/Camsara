//
//  MainView.swift
//  Camsara
//
//  Created by justin on 11.12.2025.
//

import Combine
import SwiftUI


struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        let config = WheelPickerView.Config(
            steps: Array(
                Int(viewModel.cameraService.deviceFocalLength)...Defaults.maxFocalLength
            ),
            mainSteps: Set(Defaults.mainFocalLengths)
        )

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                FrameView(viewModel: viewModel.frameViewModel)

                HStack {
                    WheelPickerView(
                        config: config,
                        viewModel: viewModel.pickerViewModel
                    )
                    .frame(width: geometry.size.width * 0.1)

                    Spacer()
                        .background(.green)

                    HueRingsView(viewModel: viewModel.hueRingsViewModel)
                        .frame(width: geometry.size.width * 0.1)

                    Spacer()
                        .frame(width: geometry.size.width * 0.1)
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}
