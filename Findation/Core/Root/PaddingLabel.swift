//  루틴 옆에 있는 태그 명 패딩하는 거
//  PaddingLabel.swift
//  again
//
//  Created by 변관영 on 8/5/25.
//

import UIKit

class PaddingLabel: UILabel {
    var topInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 0
    var rightInset: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
