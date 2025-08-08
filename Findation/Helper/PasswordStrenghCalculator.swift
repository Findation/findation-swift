//
//  PasswordStrenghCalculator.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import Foundation

func calculateStrength(password: String) -> Int {
    var strength = 0
    if password.count >= 8 { strength += 1 }
    if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
    if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
    if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { strength += 1 }
    if password.count >= 12 { strength += 1 }
    return min(strength, 5)
}
