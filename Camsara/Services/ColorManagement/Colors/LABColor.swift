//
//  LABColor.swift
//  Camsara
//
//  Created by justin on 9/1/26.
//

import UIKit


struct LABColor {
    let l: Double
    let a: Double
    let b: Double
}

extension LABColor {
    init(_ hsb: HSBColor) {
        self.init(RGBColor(hsb))
    }

    init(_ rgb: RGBColor) {
        self = LABColor.rgbToLab(rgb)
    }

    static func rgbToLab(_ rgb: RGBColor) -> LABColor {
        func linearize(_ c: Double) -> Double {
            c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        let r = linearize(rgb.r)
        let g = linearize(rgb.g)
        let b = linearize(rgb.b)

        // sRGB → XYZ (D65)
        let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
        let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
        let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

        // XYZ → LAB
        func f(_ t: Double) -> Double {
            let d = 6.0 / 29.0
            return t > pow(d, 3) ? pow(t, 1 / 3) : t / (3 * d * d) + 4 / 29
        }

        let xn = 0.95047
        let yn = 1.0
        let zn = 1.08883

        let fx = f(x / xn)
        let fy = f(y / yn)
        let fz = f(z / zn)

        return LABColor(
            l: 116 * fy - 16,
            a: 500 * (fx - fy),
            b: 200 * (fy - fz)
        )
    }
}


extension LABColor {
    static func convertToLAB(color: UIColor) -> (l: Double, a: Double, b: Double) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0

        color.getRed(
            &r,
            green: &g,
            blue: &b,
            alpha: nil
        )

        return LABColor.rgbToLAB(r: r, g: g, b: b)
    }

    static func rgbToLAB(r: Double, g: Double, b: Double) -> (l: Double, a: Double, b: Double) {
        // Преобразование sRGB -> линейный RGB
        let rLinear = if r > 0.04045 {
            pow((r + 0.055) / 1.055, 2.4)
        } else {
            r / 12.92
        }

        let gLinear = if g > 0.04045 {
            pow((g + 0.055) / 1.055, 2.4)
        } else {
            g / 12.92
        }

        let bLinear = if b > 0.04045 {
            pow((b + 0.055) / 1.055, 2.4)
        } else {
            b / 12.92
        }

        // XYZ матрица для D65
        let x = rLinear * 0.4124564 + gLinear * 0.3575761 + bLinear * 0.1804375
        let y = rLinear * 0.2126729 + gLinear * 0.7151522 + bLinear * 0.0721750
        let z = rLinear * 0.0193339 + gLinear * 0.1191920 + bLinear * 0.9503041

        // XYZ -> LAB с D65 белой точкой
        let xn = 0.95047
        let yn = 1.00000
        let zn = 1.08883

        let f = { (t: Double) -> Double in
            let delta = 6.0 / 29.0

            return if t > pow(delta, 3) {
                pow(t, 1.0 / 3.0)
            } else {
                t / (3 * pow(delta, 2)) + 4.0 / 29.0
            }
        }

        let fx = f(x / xn)
        let fy = f(y / yn)
        let fz = f(z / zn)

        let l = 116 * fy - 16
        let a = 500 * (fx - fy)
        let bLab = 200 * (fy - fz)

        return (l, a, bLab)
    }

    static func distance(between lab1: LABColor, and lab2: LABColor) -> Double {
        let dl = lab1.l - lab2.l
        let da = lab1.a - lab2.a
        let db = lab1.b - lab2.b

        return sqrt(dl * dl + da * da + db * db)
    }

    static func average(colors: [LABColor]) -> LABColor {
        guard !colors.isEmpty else {
            return LABColor(
                l: 0,
                a: 0,
                b: 0
            )
        }

        var sumL = 0.0
        var sumA = 0.0
        var sumB = 0.0

        for color in colors {
            sumL += color.l
            sumA += color.a
            sumB += color.b
        }

        let count = Double(colors.count)

        return LABColor(l: sumL / count, a: sumA / count, b: sumB / count)
    }

    // MARK: - Instance Methods

    func distance(to other: LABColor) -> Double {
        return LABColor.distance(between: self, and: other)
    }

    func toRGB() -> (r: Double, g: Double, b: Double) {
        // LAB -> XYZ
        let fy = (l + 16) / 116
        let fx = a / 500 + fy
        let fz = fy - b / 200

        let delta = 6.0 / 29.0

        let inverseF = { (t: Double) -> Double in
            return if t > delta {
                pow(t, 3)
            } else {
                3 * pow(delta, 2) * (t - 4.0 / 29.0)
            }
        }

        let xn = 0.95047
        let yn = 1.00000
        let zn = 1.08883

        let x = xn * inverseF(fx)
        let y = yn * inverseF(fy)
        let z = zn * inverseF(fz)

        // XYZ -> линейный RGB
        var rLinear = 3.2404542 * x - 1.5371385 * y - 0.4985314 * z
        var gLinear = -0.9692660 * x + 1.8760108 * y + 0.0415560 * z
        var bLinear = 0.0556434 * x - 0.2040259 * y + 1.0572252 * z

        // Гамма коррекция (линейный RGB -> sRGB)
        rLinear = if rLinear > 0.0031308 {
            1.055 * pow(rLinear, 1.0 / 2.4) - 0.055
        } else {
            12.92 * rLinear
        }

        gLinear = if gLinear > 0.0031308 {
            1.055 * pow(gLinear, 1.0 / 2.4) - 0.055
        } else {
            12.92 * gLinear
        }

        bLinear = if bLinear > 0.0031308 {
            1.055 * pow(bLinear, 1.0 / 2.4) - 0.055
        } else {
            12.92 * bLinear
        }

        // Ограничение диапазона
        let r = min(max(rLinear, 0), 1)
        let g = min(max(gLinear, 0), 1)
        let b = min(max(bLinear, 0), 1)

        return (r, g, b)
    }
}

//extension LABColor {
//    init(_ color: UIColor) {
//        let lab = LABColor.convertToLAB(color: color)
//
//        self.init(
//            l: lab.l,
//            a: lab.a,
//            b: lab.b
//        )
//    }
//
//    init(_ color: RGBColor) {
//        let lab = LABColor.rgbToLAB(
//            r: color.r,
//            g: color.g,
//            b: color.b
//        )
//
//        self.init(
//            l: lab.l,
//            a: lab.a,
//            b: lab.b
//        )
//    }
//}

//extension RGBColor {
//    init(_ color: LABColor) {
//        let rgb = color.toRGB()
//
//        self.init(
//            r: rgb.r,
//            g: rgb.g,
//            b: rgb.b
//        )
//    }
//}
//
//extension UIColor {
//    convenience init(labColor: LABColor) {
//        let rgb = labColor.toRGB()
//
//        self.init(
//            red: rgb.r,
//            green: rgb.g,
//            blue: rgb.b,
//            alpha: 1
//        )
//    }
//}
