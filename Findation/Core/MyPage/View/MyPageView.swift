import SwiftUI

struct MyPageScreen: View {
    @State private var fishBobbingOffset: CGFloat = 0
    @State private var isShowingMenu = false  // 메뉴뷰로 이동 트리거

    let fishtankHeight: CGFloat = 705
    let targetFishYCenter: CGFloat = 370

    var body: some View {
        NavigationStack {
            ZStack {
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

                                        // 햄버거 버튼 → MenuView로 이동
                                        NavigationLink(destination: MenuView()) {
                                            Image("hamburger")
                                                .padding(.trailing, 20)
                                        }
                                        .contentShape(Rectangle())
                                    }

                                    VStack(spacing: 40) {
                                        StatusBubbleView(text: "요즘 집중이 부족해서 배고파요ㅠㅠ")
                                        Image("fish")
                                    }
                                    .offset(y: targetFishYCenter - (fishtankHeight / 2) + fishBobbingOffset)
                                    .onAppear {
                                        startFishBobbingAnimation()
                                    }
                                }
                                .padding(.bottom, 120)
                            }

                            VStack {
                                Text("아래 콘텐츠")
                                    .font(.title)
                                Spacer()
                            }
                        }

                        VStack {
                            CollectView()
                            FocusRecoveryView()
                        }
                        .padding(.top, 530)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .background(Color("Primary"))
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func startFishBobbingAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            fishBobbingOffset = -20
        }
    }
}
