//
//  ClosedRange+Extension.swift
//  Camsara
//
//  Created by justin on 23.12.2025.
//


extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        if value < lowerBound {
            lowerBound
        } else if value > upperBound {
            upperBound
        } else {
            value
        }
    }
}
