//
//  FriendsAddView.swift
//  again
//
//  Created by 변관영 on 8/6/25.
//

import SwiftUI

struct MyPage: View {
    @State private var fishBobbingOffset: CGFloat = 0

    let fishtankHeight: CGFloat = 705
    let targetFishYCenter: CGFloat = 370
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ZStack {
                            Image("fishtank")
                                .resizable()
                                .scaledToFill()
                                .frame(height: fishtankHeight)
                                .clipped()

                            VStack(spacing: 60) {
                                HStack {
                                    Text("세이님의 어항")
                                        .foregroundColor(.white)
                                        .frame(width: 205, height: 33)
                                        .frame(maxWidth: .infinity)
                                        .overlay(
                                            NavigationLink(destination: MenuView()) {
                                                Image("hamburger")
                                                    .padding(.trailing, 20)
                                                    .contentShape(Rectangle())
                                            }
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        )
                                }

                                VStack(spacing: 40){
                                    StatusBubbleView(text: "요즘 집중이 부족해서 배고파요ㅠㅠ")

                                    Image("fish")
                                }
                                    .offset(y: targetFishYCenter - (fishtankHeight / 2) + fishBobbingOffset)
                                    .onAppear {
                                        startFishBobbingAnimation()
                                    }
                            }
                            .padding(.bottom, 120) // 기존 패딩 유지
                        }

                        VStack {
                            Text("아래 콘텐츠")
                                .font(.title)

                            Spacer()
                        }
                    }

                    VStack{
                        PhotoCollectionView()
                        PhotoCollectionView()
                    }
                    .padding(.top, 530)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .background(Color("Primary"))
            .navigationBarHidden(true) // 기본 내비게이션 바 숨김
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func startFishBobbingAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            fishBobbingOffset = -20
        }
    }
}


