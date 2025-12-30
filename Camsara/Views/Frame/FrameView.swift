//
//  FrameView.swift
//  Camsara
//
//  Created by justin on 20.12.2025.
//

import AVFoundation
import Combine
import SwiftUI


struct FrameView: View {
    @ObservedObject var viewModel: FrameViewModel

    var body: some View {
        ZStack {
            CameraPreviewViewHolder(session: viewModel.session)
                .background(.red)
                .ignoresSafeArea()

            ZStack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.green.opacity(0.2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Rectangle()
                        .fill(.white)
                        .frame(
                            width: geometry.size.width * viewModel.scaleFactor,
                            height: geometry.size.height * viewModel.scaleFactor
                        )
                        .position(
                            x: geometry.size.width * 0.5,
                            y: geometry.size.height * 0.5
                        )
                        .blendMode(.destinationOut)
                }
            }
            .compositingGroup()
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}
