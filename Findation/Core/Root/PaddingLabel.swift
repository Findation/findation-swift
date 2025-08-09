import UIKit

class PaddingLabel: UILabel {
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset,
                                  bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + leftInset + rightInset
        let height = superContentSize.height + topInset + bottomInset
        return CGSize(width: width, height: height)
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: UIEdgeInsets(top: topInset, left: leftInset,
                                                        bottom: bottomInset, right: rightInset))
        let rect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -topInset, left: -leftInset,
                                          bottom: -bottomInset, right: -rightInset)
        return rect.inset(by: invertedInsets)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = bounds.width - leftInset - rightInset
    }
}
