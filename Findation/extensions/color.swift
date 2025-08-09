//
//  color.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import Foundation
import SwiftUI

extension Color {
    static let primaryColor = Color("Primary")
    static let secondaryColor = Color("Secondary")
    static let darkGrayColor = Color("DarkGray")
    static let mediumGrayColor = Color("MediumGray")
    static let lightGrayColor = Color("LightGray")
    static let redColor = Color("Red")
    static let blackColor = Color("Black")
    
    init(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)

            let r = Double((rgb >> 16) & 0xFF) / 255.0
            let g = Double((rgb >> 8) & 0xFF) / 255.0
            let b = Double(rgb & 0xFF) / 255.0

            self.init(red: r, green: g, blue: b)
    }
}
