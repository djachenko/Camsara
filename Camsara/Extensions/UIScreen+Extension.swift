//
//  UIScreen+Extension.swift
//  Camsara
//
//  Created by justin on 01.01.2026.
//

import UIKit


enum ScreenSize: Int {
    case screen4Inch
    case screen4Dot7Inch
    case screen5Dot5Inch
    case screenUnknown
}

extension UIScreen {
    static var perfectPixel: Double {
        1.0 / main.scale
    }

    static var screenSize: ScreenSize {
        let height = max(main.bounds.size.height, main.bounds.size.width)

        if height == 568 {
            return .screen4Inch
        } else if height == 667 {
            return .screen4Dot7Inch
        } else if height == 736 {
            return .screen5Dot5Inch
        } else {
            return .screenUnknown
        }
    }

    static var isIPhoneWithBigScreen: Bool {
        screenSize != .screen4Inch
    }
}
