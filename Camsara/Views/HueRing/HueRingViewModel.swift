//
//  HueRingViewModel.swift
//  Camsara
//
//  Created by justin on 12/1/26.
//

import Combine
import Foundation


class HueRingViewModel: ObservableObject {
    @Published var markers: [HueMarker] = []

    private var cancellables = Set<AnyCancellable>()

    init(colorsSource: ColorsSource) {
        colorsSource.colors
            .map {
                $0.map {
                    HueMarker($0)
                }
            }
            .receive(on: RunLoop.main)
            .assign(to: &$markers)

        colorsSource.colors.sink {
            print($0.map(\.r))
            print($0.map(\.g))
            print($0.map(\.b))
            print("HSBColor", $0.map(HSBColor.init).map(\.h))
            print($0.map(HueMarker.init).map(\.hue))
            print()
        }.store(in: &cancellables)
    }
}

extension HueRingViewModel {
    static let forPreview = HueRingViewModel(colorsSource: MockColorsSource())
}
