//
//  OnboardingView.swift
//  Findation
//
//  Created by 변관영 on 8/3/25.
//

import SwiftUI

// MARK: - 헥사 코드 색상 지원
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - 모델
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String?
}

let activities: [Activity] = [
    Activity(name: "공부/자기계발", imageName: "study"),
    Activity(name: "독서", imageName: "books"),
    Activity(name: "글쓰기/일기", imageName: "write"),
    Activity(name: "자격증/언어", imageName: "lan"),
    Activity(name: "운동/스포츠", imageName: "exe"),
    Activity(name: "여행/산책", imageName: "walk"),
    Activity(name: "음악/악기", imageName: "music"),
    Activity(name: "예술/창작", imageName: "make"),
    Activity(name: "공연/전시", imageName: "art"),
    Activity(name: "사진/영상", imageName: "photo"),
    Activity(name: "요리", imageName: "cook"),
    Activity(name: "기타", imageName: "others")
]

// MARK: - 온보딩 뷰
struct OnboardingView: View {
    @State private var selectedActivities: Set<String> = []
    @State private var navigateToMain = false
    @State private var showError = false
    @State private var activeActivityID: UUID?

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(spacing: 0) {

                    // 헤더
                    VStack(alignment: .leading, spacing: 8) {
                        Text("관심 있는 활동을 선택해주세요.")
                            .font(.title2).bold()
                        Text("선택하신 카테고리를 기반으로 AI가 활동을 추천해드려요.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 220)
                    .padding(.bottom, 50)

                    // 활동 선택 그리드
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        ForEach(activities) { activity in
                            ZStack(alignment: .bottom) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        if let imageName = activity.imageName {
                                            Image(imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: geo.size.width * 0.22, height: geo.size.width * 0.22)
                                                .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(width: geo.size.width * 0.22, height: geo.size.width * 0.22)
                                        }

                                        Circle()
                                            .stroke(
                                                selectedActivities.contains(activity.name)
                                                ? Color(hex: "#498FFF")
                                                : Color(hex: "#D9D9D9"),
                                                lineWidth: 2
                                            )
                                            .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)

                                        if selectedActivities.contains(activity.name) {
                                            Circle()
                                                .fill(Color(hex: "#498FFF").opacity(0.4))
                                                .frame(width: geo.size.width * 0.25, height: geo.size.width * 0.25)

                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                    }

                                    Text(activity.name)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }

                                if activeActivityID == activity.id {
                                    Rectangle()
                                        .fill(Color(hex: "#D9D9D9"))
                                        .frame(height: geo.size.width * 0.25)
                                        .cornerRadius(12)
                                        .opacity(0.6)
                                        .transition(.opacity)
                                        .animation(.easeInOut(duration: 0.5), value: activeActivityID)
                                }
                            }
                            .onTapGesture {
                                if selectedActivities.contains(activity.name) {
                                    selectedActivities.remove(activity.name)
                                } else {
                                    selectedActivities.insert(activity.name)
                                }
                                showError = false
                            }
                            .onLongPressGesture {
                                activeActivityID = activity.id
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)

                    Spacer()
                    Spacer(minLength: 30)

                    VStack(spacing: 10) {
                        Button(action: {
                            if selectedActivities.count >= 3 {
                                navigateToMain = true
                            } else {
                                showError = true
                            }
                        }) {
                            Text("제출하기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }

                        Text("최소 3개 이상 선택해주세요.")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .opacity(showError ? 1 : 0)
                            .frame(height: 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 40)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.white)
                .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $navigateToMain) {
            }
        }
    }
}

// MARK: - ContentView Preview

#Preview{
    OnboardingView()
}
