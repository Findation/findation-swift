import UIKit

extension UIColor {
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
