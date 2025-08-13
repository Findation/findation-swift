import SwiftUI

struct MyPageScreen: View {
    let nickname = KeychainHelper.load(forKey: "nickname") ?? "어푸"
    @State private var fishBobbingOffset: CGFloat = 0
    
    let fishtankHeight: CGFloat = 705
    let targetFishYCenter: CGFloat = 370
    
    struct FocusRankingPagedSection: View {
        @State private var page = 0
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                
                // 카드 안에 TabView를 넣고, 하단에 커스텀 페이지 컨트롤 오버레이
                ZStack(alignment: .bottom) {
                    // 콘텐츠
                    TabView(selection: $page) {
                        // 기존 달력/집중 뷰를 그대로 사용
                        FocusRecoveryView()
                            .tag(0)
                        
                        RankingView()
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never)) // 기본 점 숨김
                    .frame(height: 420) // 두 뷰 공통 높이
                    .shadow(radius: 10)
                    
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 8)
        }
    }
    
    /// 간단한 페이지 점
    private struct PageDots: View {
        let count: Int
        let currentIndex: Int
        
        var body: some View {
            HStack(spacing: 8) {
                ForEach(0..<count, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentIndex ? Color("Primary") : Color.gray.opacity(0.3))
                        .frame(width: idx == currentIndex ? 10 : 8, height: idx == currentIndex ? 10 : 8)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ZStack {
                            ZStack{
                                Image("fishtank")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .edgesIgnoringSafeArea(.top)
                            }
                            
                            VStack(spacing: 80) {
                                HStack {
                                    Text("\(nickname)님의 어항")
                                        .title1()
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
                                        .shadow(color: Color("Primary"), radius: 4, x: 0, y: 2)
                                    
                                    Image("fish_sunglasses")
                                }
                                .offset(y: targetFishYCenter - (fishtankHeight / 2) + fishBobbingOffset)
                                .onAppear {
                                    startFishBobbingAnimation()
                                }
                            }
                            .padding(.bottom, 800)
                        }
                        
                        VStack {
                            Spacer()
                        }
                    }
                    
                    VStack(spacing: -20){
                        CollectedChangeView()
                            .shadow(radius: 10)
                        FocusRankingPagedSection()
                            .shadow(radius: 10)
                    }
                    .padding(.top, 550)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .background(Color("Secondary"))
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

#Preview {
    MyPageScreen()
}
