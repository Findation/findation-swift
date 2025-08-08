//
//  OnBoardingTitle.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import SwiftUI

struct OnBoardingTitle: View {
    let title: String
    let subTitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .modifier(Title2())
            if let subTitle {
                Text(subTitle)
                    .modifier(Subhead())
                    .foregroundColor(Color.darkGray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 16)
    }
}

#Preview {
    OnBoardingTitle(title: "안녕하세요", subTitle: "서브 타이틀입니다")
}
