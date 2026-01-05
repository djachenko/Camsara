//
//  WheelPickerView.swift
//  Camsara
//
//  Created by justin on 15.12.2025.
//

import Combine
import SwiftUI


struct WheelPickerView: View {
    struct Config {
        let steps: [Int]
        let mainSteps: Set<Int>
        private(set) var spacing = 5.0
    }

    struct UIConfig {
        private static let markerWidth = 10.0

        let markerWidth = markerWidth
        let mainMarkerWidth = 2 * markerWidth

        let markerColor = Color.white
        let mainMarkerColor = Color.white

        let indicatorColor = Color.white

        let labelsColor = Color.white
    }

    let config: Config
    private let uiConfig = UIConfig()

    @State private var isLoaded = false

    @ObservedObject var viewModel: WheelPickerViewModel

    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.height / 2

            if #available(iOS 17.0, *) {
                ScrollView(.vertical) {
                    VStack(spacing: config.spacing) {
                        ForEach(config.steps, id: \.self) { index in
                            let isMain = config.mainSteps.contains(index)

                            let color = if isMain {
                                uiConfig.mainMarkerColor
                            } else {
                                uiConfig.markerColor
                            }

                            let markerWidth = if isMain {
                                uiConfig.mainMarkerWidth
                            } else {
                                uiConfig.markerWidth
                            }

                            Divider()
                                .background(color)
                                .frame(
                                    width: markerWidth,
                                    height: 0,
                                    alignment: .center
                                )
                                .frame(
                                    maxWidth: uiConfig.mainMarkerWidth,
                                    alignment: .leading
                                )
                                .overlay(alignment: .trailing) {
                                    if isMain {
                                        let orientParams = OrientationParameters.parameters(
                                            for: viewModel.orientation
                                        )

                                        Text("\(index)")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .textScale(.secondary)
                                            .foregroundStyle(uiConfig.labelsColor)
                                            .fixedSize()
                                            .offset(
                                                x: orientParams.offsetX,
                                                y: orientParams.offsetY
                                            )
                                            .rotationEffect(.degrees(Double(orientParams.angle)))
                                    }
                                }
                        }
                    }
                    .background(.clear)
                    .frame(width: size.width)
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(
                    id: .init(
                        get: {
                            if isLoaded {
                                viewModel.pickerValue
                            } else {
                                nil
                            }
                        },
                        set: { newValue in
                            if let newValue {
                                viewModel.pickerValue = newValue
                            }
                        }
                    )
                )
                .overlay(alignment: .center) {
                    Rectangle()
                        .fill(uiConfig.indicatorColor)
                        .frame(
                            width: 40,
                            height: 1
                        )
                        .padding(.trailing, 20)
                }
                .safeAreaPadding(.vertical, horizontalPadding)
                .onAppear {
                    if !isLoaded {
                        isLoaded = true
                    }
                }
            } else {
                WheelPickerUIViewHolder(
                    config: config,
                    uiConfig: uiConfig,
                    verticalInset: horizontalPadding,
                    viewModel: viewModel
                )
            }
        }
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}
