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
                .scaleEffect(viewModel.previewScale)
                .background(.black)
                .ignoresSafeArea()

            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        viewModel.update(size: geometry.size)
                    }
                    .onChange(of: geometry.size, perform: viewModel.update(size:))
            }

            ZStack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.black.opacity(0.3))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)


                    let holeWidth = geometry.size.width * viewModel.frameScale
                    let holeHeight = holeWidth * 2 / 3

                    Rectangle()
                        .fill(.white)
                        .frame(
                            width: holeWidth,
                            height: holeHeight
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
