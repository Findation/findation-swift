import UIKit

class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + textInsets.left + textInsets.right,
                      height: s.height + textInsets.top + textInsets.bottom)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
        if #available(iOS 13.0, *) { layer.cornerCurve = .continuous }
    }
}
