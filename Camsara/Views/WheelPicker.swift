//
//  WheelPicker.swift
//  Camsara
//
//  Created by justin on 15.12.2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var value = 10
    @State private var config = WheelPicker.Config(
        steps: Array(24...Defaults.maxFocalLength),
        mainSteps: Set(Defaults.mainFocalLengths)
    )

    var body: some View {
        ZStack {
            Color.yellow

            HStack {
                WheelPicker(
                    config: config,
                    value: $value
                )
                .frame(width: 60)

                VStack {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text("\(value)")
                            .font(.largeTitle.bold())
                            .contentTransition(.numericText(value: Double(value)))
                            .animation(
                                .snappy,
                                value: value
                            )
                            .frame(width: 80)
                            .background(.red)

                        Text("lbs")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textScale(.secondary)
                            .foregroundStyle(.gray)
                    }

                    Button("Update") {
                        withAnimation {
                            value = 11
                        }
                    }
                }
                .padding(.bottom, 30)


            }
        }
    }
}


struct WheelPicker: View {
    struct Config {
        let steps: [Int]
        let mainSteps: Set<Int>
        private(set) var spacing = 5.0
    }

    var config: Config
    @Binding var value: Int
    @State private var isLoaded = false

    var body: some View {
        GeometryReader {
            let size = $0.size
            let horizontalPadding = size.height / 2

            ScrollView(.vertical) {
                VStack(spacing: config.spacing) {
                    ForEach(config.steps, id: \.self) { index in
                        let isMain = config.mainSteps.contains(index)

                        Divider()
                            .background(isMain ? Color.primary : .gray)
                            .frame(
                                width: isMain ? 20 : 10,
                                height: 0,
                                alignment: .center
                            )
                            .frame(
                                maxWidth: 20,
                                alignment: .leading
                            )
                            .overlay(alignment: .trailing) {
                                if isMain {
                                    Text("\(index)")
//                                    Text("\(Int(Double(index / config.steps) * config.multiplier))")
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
        }
    }
}

#Preview {
    ContentView()
}
