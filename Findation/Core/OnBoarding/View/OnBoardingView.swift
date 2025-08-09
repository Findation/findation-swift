//
//  OnBoardingView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var shouldNavigateToNextScreen: Bool = false
    @State private var selectedActivities: Set<String> = []
    @State private var showError = false
    @State private var activeActivityID: UUID?

    var body: some View {
        NavigationStack {
            VStack() {
                OnBoardingTitle(title:"관심 있는 활동을 선택해주세요.", subTitle:"선택하신 카테고리를 기반으로 AI가 활동을 추천해드려요.")
                // 활동 선택 그리드
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    ForEach(activities) { activity in
                        ActivityCell(selectedActivities: $selectedActivities, activeActivityID: $activeActivityID, showError: $showError, activity: activity)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                    .frame(height: 20)
                
                SubmitButton(showError: $showError, shouldNavigateToNextScreen: $shouldNavigateToNextScreen,isSatisfied: selectedActivities.count >= 3, label: "시작하기") {
                    // TODO: 유저 흥미 추가
                }
                
                Spacer()
                    .frame(height: 20)

                Text("3개 이상의 활동을 선택해주세요.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 16)
                    .opacity(showError ? 1 : 0)
                    .padding(.bottom, 10)
            }
            .navigationDestination(isPresented: $shouldNavigateToNextScreen) {
                OnboardingView()
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
}
