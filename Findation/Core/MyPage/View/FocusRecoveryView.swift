//
//  MyPageView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct FocusRecoveryView: View {
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("집중력 회복")
                .font(.body)
                .foregroundColor(.black)
                .padding(.top, 17)
                .padding(.leading, 18)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .frame(width: 353, height: 350)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 8)
    }
}

// struct SmoothGraphView: View {
//      let dataPoints: [CGFloat]

// 외부에서 데이터를 받아오는 거 구현하는 부분은 일단 공백으로 둘게요!
// 벡엔드 구현되면 다시 해보겠습니다! 그 때 하는 게 좋을 거 같아욥

        
        
#Preview {
    FocusRecoveryView()
}
