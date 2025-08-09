//
//  RepeatedBitmast.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

func calculateMaskMonFirst(_ weekdays: [Bool]) -> Int {
    var mask = 0
    for (i, on) in weekdays.enumerated() where on {
        mask |= (1 << i)
    }
    return mask
}

func decodeMaskMonFirst(_ mask: Int) -> [Bool] {
    (0..<7).map { ((mask >> $0) & 1) == 1 }
}

func isScheduledOnDate(bitmask: Int, date: Date, calendar: Calendar = .current) -> Bool {
     let weekday = calendar.component(.weekday, from: date)
     let index = (weekday + 5) % 7
     return (bitmask & (1 << index)) != 0
}
