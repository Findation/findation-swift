//
//  MyPageView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct CollectView: View {
    
    var body: some View {
        
        VStack(alignment: .leading){
            Text("모아보기")
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

    
#Preview {
    CollectView()
}
