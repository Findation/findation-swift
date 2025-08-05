//
//  RepeatedBitmast.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

func calculateIsRepeatedBitmask(_ weekdays: [Bool]) -> Int {
    var result = 0
    for (index, selected) in weekdays.enumerated() {
        if selected {
            result |= (1 << (6 - index))
        }
    }
    return result
}

func decodeIsRepeatedBitmask(_ bitmask: Int) -> [Bool] {
    var result: [Bool] = []

    for i in 0..<7 {
        let bit = (bitmask >> (6 - i)) & 1
        result.append(bit == 1)
    }

    return result
}
