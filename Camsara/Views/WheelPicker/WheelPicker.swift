//
//  WheelPicker.swift
//  Camsara
//
//  Created by justin on 15.12.2025.
//

import SwiftUI
import Combine


struct WheelPicker: View {
    struct Config {
        let steps: [Int]
        let mainSteps: Set<Int>
        private(set) var spacing = 5.0
    }

    struct UIConfig {
        private static let markerWidth = 10.0

        let markerWidth = markerWidth
        let mainMarkerWidth = 2 * markerWidth

        let markerColor = Color.primary
        let mainMarkerColor = Color.primary
    }

    let config: Config
    private let uiConfig = UIConfig()

    @Binding var value: Int
    @State private var isLoaded = false

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
                                        Text("\(index)")
                                        // Text("\(Int(Double(index / config.steps) * config.multiplier))")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .textScale(.secondary)
                                            .fixedSize()
                                            .offset(x: 20)
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
                                value
                            } else {
                                nil
                            }
                        },
                        set: { newValue in
                            if let newValue {
                                value = newValue
                            }
                        }
                    )
                )
                .overlay(alignment: .center) {
                    Rectangle()
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
                    verticalInset: horizontalPadding
                )
            }
        }
    }
}

#Preview {
    MainView(viewModel: .forPreview)
}
