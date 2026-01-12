//
//  ColorSchemeGenerator.swift
//  Camsara
//
//  Created by justin on 12/1/26.
//


func wrapHue(_ value: Double) -> Double {
    let r = value.truncatingRemainder(dividingBy: 1.0)
    return r < 0 ? r + 1.0 : r
}

struct ColorSchemeGenerator {

    static func complementary(from base: Double) -> [Double] {
        arbitrary(from: base, count: 2)
    }

    static func triad(from base: Double) -> [Double] {
        arbitrary(from: base, count: 3)
    }

    static func tetrad(from base: Double) -> [Double] {
        arbitrary(from: base, count: 4)
    }

    static func arbitrary(from base: Double, count: Int) -> [Double] {
        guard count > 0 else {
            return []
        }

        let step = 1.0 / Double(count)

        return (0..<count).map { i in
            wrapHue(base + Double(i) * step)
        }
    }
}