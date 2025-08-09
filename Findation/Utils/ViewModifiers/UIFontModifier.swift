//
//  UIFontModifier.swift
//  Findation
//
//  Created by 변관영 on 8/8/25.
//

import UIKit

extension UIFont {
    
    static var largeTitle: UIFont {
        UIFont.systemFont(ofSize: 34, weight: .regular)
    }

    static var title1: UIFont {
        UIFont.systemFont(ofSize: 28, weight: .regular)
    }

    static var title2: UIFont {
        UIFont.systemFont(ofSize: 22, weight: .regular)
    }

    static var title3: UIFont {
        UIFont.systemFont(ofSize: 20, weight: .regular)
    }

    static var headline: UIFont {
        UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    static var bodytext: UIFont {
        UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static var callOut: UIFont {
        UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static var subhead: UIFont {
        UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    static var footnote: UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    static var caption1: UIFont {
        UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    static var caption2: UIFont {
        UIFont.systemFont(ofSize: 11, weight: .regular)
    }

    static var timeLarge: UIFont {
        UIFont.systemFont(ofSize: 64, weight: .ultraLight)
    }

    static var timeSmall: UIFont {
        UIFont.systemFont(ofSize: 48, weight: .ultraLight)
    }
    
        static var Primary: UIColor {
            return UIColor(named: "Primary", in: Bundle.main, compatibleWith: nil) ?? .systemBlue
        }

        static var Secondary: UIColor {
            return UIColor(named: "Secondary", in: Bundle.main, compatibleWith: nil) ?? .lightGray
        }

        static var MediumGray: UIColor {
            return UIColor(named: "MediumGray", in: Bundle.main, compatibleWith: nil) ?? .gray
        }

        static var DarkGray: UIColor {
            return UIColor(named: "DarkGray", in: Bundle.main, compatibleWith: nil) ?? .darkGray
        }

        static var LightGray: UIColor {
            return UIColor(named: "LightGray", in: Bundle.main, compatibleWith: nil) ?? .lightGray
        }

        static var Black: UIColor {
            return UIColor(named: "Black", in: Bundle.main, compatibleWith: nil) ?? .black
        }
    }

