//
//  HueMarker.swift
//  Camsara
//
//  Created by justin on 11/1/26.
//

import Foundation


struct HueMarker: Identifiable {
    let id = UUID()
    let hue: Double // 0...1
}

extension HueMarker {
    init(_ color: RGBColor) {
        self.init(HSBColor(color))
    }

    init(_ color: HSBColor) {
        self.init(hue: color.h)
    }
}
