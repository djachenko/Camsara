//
//  HSBColor.swift
//  Camsara
//
//  Created by justin on 10/1/26.
//


struct HSBColor {
    let h: Double // 0.0 - 360.0
    let s: Double // 0.0 - 1.0
    let b: Double // 0.0 - 1.0
}

extension HSBColor {
    init(_ rgb: RGBColor) {
        let r = rgb.r
        let g = rgb.g
        let b = rgb.b

        let maxV = max(r, g, b)
        let minV = min(r, g, b)
        let delta = maxV - minV

        var h = 0.0

        let s: Double = if maxV == 0 {
            0.0
        } else {
            delta / maxV
        }

        let v = maxV

        if delta > 0 {
            if maxV == r {
                h = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
            } else if maxV == g {
                h = 60 * (((b - r) / delta) + 2)
            } else {
                h = 60 * (((r - g) / delta) + 4)
            }
        }

        if h < 0 { h += 360 }

        self.init(
            h: h,
            s: s,
            b: v
        )
    }

    init(_ lab: LABColor) {
        self.init(RGBColor(lab))
    }
}
