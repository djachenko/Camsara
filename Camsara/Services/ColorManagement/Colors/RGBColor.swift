//
//  RGBColor.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import Foundation


struct RGBColor {
    let r: Double
    let g: Double
    let b: Double
}

extension RGBColor {
    init(_ hsb: HSBColor) {
        let h = hsb.h.truncatingRemainder(dividingBy: 360)
        let s = min(max(hsb.s, 0), 1)
        let v = min(max(hsb.b, 0), 1)

        let c = v * s
        let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = v - c

        let (r1, g1, b1): (Double, Double, Double)

        (r1, g1, b1) = switch h {
        case 0..<60:
            (c, x, 0)
        case 60..<120:
            (x, c, 0)
        case 120..<180:
            (0, c, x)
        case 180..<240:
            (0, x, c)
        case 240..<300:
            (x, 0, c)
        default:
            (c, 0, x)
        }

        self.init(
            r: r1 + m,
            g: g1 + m,
            b: b1 + m
        )
    }

    init(_ lab: LABColor) {
        let fy = (lab.l + 16) / 116
        let fx = lab.a / 500 + fy
        let fz = fy - lab.b / 200

        func inv(_ t: Double) -> Double {
            let d = 6.0 / 29.0
            return t > d ? t * t * t : 3 * d * d * (t - 4 / 29)
        }

        let x = inv(fx) * 0.95047
        let y = inv(fy)
        let z = inv(fz) * 1.08883

        func gamma(_ c: Double) -> Double {
            c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055
        }

        self.init(
            r: min(max(gamma( 3.2404542 * x - 1.5371385 * y - 0.4985314 * z), 0), 1),
            g: min(max(gamma(-0.9692660 * x + 1.8760108 * y + 0.0415560 * z), 0), 1),
            b: min(max(gamma( 0.0556434 * x - 0.2040259 * y + 1.0572252 * z), 0), 1)
        )
    }
}


extension RGBColor {
    static let black = RGBColor(r: 0, g: 0, b: 0)
    static let gray = RGBColor(r: 0.5, g: 0.5, b: 0.5)

    static let red = RGBColor(r: 1, g: 0, b: 0)
    static let green = RGBColor(r: 0, g: 1, b: 0)
    static let blue = RGBColor(r: 0, g: 0, b: 1)
}
