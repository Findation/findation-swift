//
//  SubmitButton.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import SwiftUI

struct SubmitButton: View {
    @Binding var showError: Bool
    @Binding var shouldNavigateToNextScreen: Bool
    
    let isSatisfied: Bool
    let label: String
    let action: () async -> Void
    
    var body: some View {
        Button(action: {
            if !isSatisfied {
                showError = true
                return
            }
            showError = false
            shouldNavigateToNextScreen = true
            
            Task {
                await action()
            }
        }) {
            Text(label)
                .foregroundColor(.white)
                .modifier(Title2())
                .frame(maxWidth: .infinity)   // ✅ 텍스트를 최대 너비로
                .frame(height: 50)
                .background(isSatisfied ? Color.primaryColor : Color.darkGrayColor)
                .cornerRadius(.infinity)
                .contentShape(Rectangle())
        }
        .padding(.horizontal,40)
    }
    
}

#Preview {
    SubmitButton(showError: .constant(false), shouldNavigateToNextScreen: .constant(false), isSatisfied: true, label: "제출하기") {
        print("🔹 Preview에서 버튼 클릭됨")
    }
}
