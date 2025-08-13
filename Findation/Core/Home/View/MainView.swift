import SwiftUI
import UIKit

struct MainView: View {
    // MARK: Env / VM
    @EnvironmentObject var session: SessionStore
    @StateObject private var vm = RoutinesViewModel()

    // MARK: 헤더/리스트
    @State private var currentDate = Date()
    @State private var showAllRoutines = false
    private var todaysRoutines: [Routine] {
        vm.routines.filter { $0.matches(date: currentDate) || $0.isNotRepeated() }
    }
    private var visibleRoutines: [Routine] {
        let sorted = todaysRoutines.sorted { ($0.isCompleted ? 1 : 0) < ($1.isCompleted ? 1 : 0) }
        return showAllRoutines ? sorted : Array(sorted.prefix(5))
    }
    private var todaysBinding: Binding<[Routine]> {
        Binding(get: { visibleRoutines }, set: { _ in })
    }

    // MARK: 편집/삭제/시트/토큰
    let nickname = KeychainHelper.load(forKey: "nickname") ?? "어푸"
    @State private var showAddTask = false
    @State private var editTargetRoutine: Routine? = nil
    @State private var showDeleteConfirmation = false
    @State private var routineToDelete: Routine? = nil

    // MARK: 타이머 & 오버레이
    @State private var activeRoutine: Routine? = nil
    @State private var showTimerOverlay = false
    @State private var overlayDocked = false
    @Namespace private var overlayNS

    @State private var timerValue: TimeInterval = 0
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var dragOffset: CGFloat = 0

    // 도킹 미니바 드래그 시 살짝 떠오르는 오프셋
    @State private var dockDragYOffset: CGFloat = 0

    // MARK: 완료 플로우
    @State private var showCompletionModal = false
    @State private var elapsedSnapshot: TimeInterval = 0
    @State private var showLastModal = false
    @State private var showCamera = false
    @State private var proofImage: UIImage? = nil

    // 원 크기 비율(필요하면 여기서 조절)
    private let CIRCLE_SCALE: CGFloat = 0.62

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("Secondary").ignoresSafeArea()
             Group {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 0) {
                                    // 헤더 카드
                                    VStack(spacing: 0) {
                                        HeaderSection(
                                            date: currentDate,
                                            nickname: nickname,
                                            showAddTask: $showAddTask
                                        )
                                        .padding(.horizontal)
                                        .padding(.bottom, 18)

                                        // 루틴 리스트
                                        VStack(spacing: 0) {
                                            UIKitRoutineListView(
                                                routines: todaysBinding,
                                                onLongPressComplete: { routine in
                                                    guard !routine.isCompleted else { return }
                                                    startTimer(for: routine)
                                                },
                                                onEdit: { routine in
                                                    editTargetRoutine = routine
                                                    showAddTask = true
                                                },
                                                onDelete: { routine in
                                                    routineToDelete = routine
                                                    showDeleteConfirmation = true
                                                },
                                                onComplete: { routine in
                                                    Task { await MainActor.run { vm.markCompleted(routine.id) } }
                                                    activeRoutine = routine
                                                    showCompletionModal = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        if let last = todaysRoutines.last ?? vm.routines.last {
                                                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                                                        }
                                                    }
                                                }
                                            )
                                            .frame(height: 54 * CGFloat(visibleRoutines.count))

                                            if todaysRoutines.count > 5 {
                                                Button {
                                                    withAnimation { showAllRoutines.toggle() }
                                                } label: {
                                                    Image(systemName: showAllRoutines ? "chevron.up" : "chevron.down")
                                                        .resizable()
                                                        .frame(width: 14, height: 8)
                                                        .foregroundColor(Color(Color.primaryColor))
                                                        .padding(12)
                                                        .background(Circle().fill(Color(hex: "#EDF5FC")))
                                                }
                                                .padding(.top, 12)
                                            }
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.bottom, 20)
                                    .background(Color.white)
                                    .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
                                    .shadow(color: Color(hex: "A2C6FF"), radius: 4, x: 0, y: 2)

                                    Spacer().frame(height: 22)
                                    StatSection()
                                    Spacer().frame(height: 22)
                                    ExploreSection()
                                    Spacer().frame(height: 90)
                                }
                            }
                            .refreshable { await vm.load() }
                        }
                    }
                }
                                

                // ── 도킹 미니바 (상단 전체 파란색, 상태바 포함/날짜줄까지 가림)
                if overlayDocked, let routine = activeRoutine {
                    DockedOverlayCard(
                        routine: routine,
                        timerText: timerString(from: timerValue),
                        timerRunning: timerRunning,
                        playPauseTapped: { toggleFromDock() },
                        swipeUpToFinish: { finishFromDock() },
                        dragYOffset: $dockDragYOffset,
                        ns: overlayNS
                    )
                    .zIndex(3)
                }

                // ── 전체 오버레이(풀 화면)
                if let routine = activeRoutine {
                    ZStack {
                        Color.black.opacity(showTimerOverlay ? 0.5 : 0)
                            .ignoresSafeArea() // 스크림도 전체 덮기
                            .animation(.easeInOut(duration: 0.35), value: showTimerOverlay)

                        if showTimerOverlay {
                            fullOverlay(for: routine)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(4)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .task(id: session.isAuthenticated) {
                guard session.isAuthenticated else { return }
                await vm.load()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task { await vm.load() }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ZStack { Color.black.ignoresSafeArea(); CameraPicker { image in self.proofImage = image } }
            }
            .sheet(isPresented: $showAddTask, onDismiss: { Task { await vm.load() } }) {
                AddTaskView(routineToEdit: $editTargetRoutine).id(editTargetRoutine?.id)
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("정말 삭제하시겠어요?"),
                    message: Text("이 루틴은 삭제 후 복구할 수 없습니다."),
                    primaryButton: .destructive(Text("삭제")) {
                        if let r = routineToDelete {
                            RoutineAPI.deleteRoutine(id: r.id) { success in
                                if success,
                                   let idx = vm.routines.firstIndex(where: { $0.id == r.id }) {
                                    vm.routines.remove(at: idx)
                                }
                            }
                            routineToDelete = nil
                        }
                    },
                    secondaryButton: .cancel { routineToDelete = nil }
                )
            }
            .onDisappear { timer?.invalidate() }
            .overlay {
                if showCompletionModal, let routine = activeRoutine {
                    CompletionConfirmationView(
                        routineTitle: routine.title,
                        elapsedTime: elapsedSnapshot,
                        onComplete: {
                            Task {
                                let used = Int(elapsedSnapshot.rounded())
                                UsedTimeAPI.postUsedTime(usedTime: used, satisfaction: 5, image: nil) { _ in }
                                await MainActor.run {
                                    vm.markCompleted(routine.id)
                                    showCompletionModal = false
                                }
                            }
                        },
                        onPhotoProof: {
                            showCamera = true
                            showCompletionModal = false
                            showLastModal = true
                        },
                        onDismiss: { showCompletionModal = false }
                    )
                    .zIndex(10)
                }
                if showLastModal, let proof = proofImage, let routine = activeRoutine {
                    LastModalView(title: routine.title, proofImage: proof, showLastModal: $showLastModal) {
                        Task {
                            let used = Int(elapsedSnapshot.rounded())
                            if let data = proof.jpegData(compressionQuality: 0.8) {
                                UsedTimeAPI.postUsedTime(usedTime: used, satisfaction: 5, image: data) { _ in }
                            }
                            await MainActor.run { vm.markCompleted(routine.id) }
                        }
                    }
                    .zIndex(11)
                }
            }
        }
    }

    // MARK: - 전체 오버레이(풀 화면) – 탭바까지 완전 덮기 & 중앙정렬
    @ViewBuilder
    private func fullOverlay(for routine: Routine) -> some View {
        GeometryReader { geo in
            let topInset = UIApplication.shared.topSafeArea
            let bottomInset = UIApplication.shared.bottomSafeArea

            VStack(spacing: 0) {
                // 상단: 인사(두 줄) + 우측 상단 버튼
                ZStack {
                    VStack(spacing: 8) {
                        Text("\(nickname)님")
                            .foregroundColor(.white)
                            .title1()
                            .matchedGeometryEffect(id: "nickname", in: overlayNS)
                        Text("오늘도 힘내요!")
                            .foregroundColor(.white)
                            .title1()
                    }

                    HStack {
                        Spacer()
                        Button(action: pauseOrResumeFromOverlay) {
                            Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                                .foregroundColor(.blue)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .matchedGeometryEffect(id: "button", in: overlayNS)
                                )
                        }
                    }
                }
                .padding(.top, topInset + 24)
                .padding(.horizontal, 24)

                // 중앙: 큰 원 + 원 안(루틴명, 타이머)
                Spacer(minLength: 20)

                let circleSize = min(geo.size.width, geo.size.height) * 0.8
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: circleSize, height: circleSize)
                        .matchedGeometryEffect(id: "circle", in: overlayNS)

                    VStack(spacing: 12) {
                        Text(routine.title)
                            .foregroundColor(.white.opacity(0.85))
                            .bodytext()
                            .matchedGeometryEffect(id: "title", in: overlayNS)

                        Text(timerString(from: timerValue))
                            .foregroundColor(.white)
                            .timeLarge()
                            .matchedGeometryEffect(id: "time", in: overlayNS)
                    }
                    // 원 내부 정확 중앙 정렬 보강
                    .frame(width: circleSize, height: circleSize, alignment: .center)
                }
                .frame(maxWidth: .infinity)

                Spacer()

                // 하단 안내
                VStack(spacing: 16) {
                    Image("swipe").resizable().frame(width: 22, height: 32)
                    Text("위로 스와이프해서 종료하기")
                        .footNote()
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, bottomInset + 24)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(
                Color("Primary")
                    .matchedGeometryEffect(id: "container", in: overlayNS)
            )
            .ignoresSafeArea(.all) // ← 탭바/홈 인디케이터까지 전부 덮기
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { v in if v.translation.height < 0 { dragOffset = v.translation.height } }
                    .onEnded { v in
                        if v.translation.height < -150 {
                            withAnimation(.easeInOut(duration: 0.3)) { dragOffset = -geo.size.height }
                            elapsedSnapshot = timerValue
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showTimerOverlay = false
                                dragOffset = 0
                                endTimer()
                                showCompletionModal = true
                            }
                        } else {
                            withAnimation { dragOffset = 0 }
                        }
                    }
            )
        }
    }

    // MARK: - 도킹된 미니바(상단 전체, 상태바 포함)
    private func DockedOverlayCard(
        routine: Routine,
        timerText: String,
        timerRunning: Bool,
        playPauseTapped: @escaping () -> Void,
        swipeUpToFinish: @escaping () -> Void,
        dragYOffset: Binding<CGFloat>,
        ns: Namespace.ID
    ) -> some View {
        let topInset = UIApplication.shared.topSafeArea

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(routine.title)
                        .foregroundColor(.white)
                        .bodytext()
                        .matchedGeometryEffect(id: "title", in: ns)

                    Text(timerText)
                        .foregroundColor(.white)
                        .timeLarge()
                        .matchedGeometryEffect(id: "time", in: ns)
                }
                Spacer()
                Button(action: playPauseTapped) {
                    Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(Color("Primary"))
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .matchedGeometryEffect(id: "button", in: ns)
                        )
                }
            }
            .padding(.top, topInset + 20)
            .padding(.horizontal, 20)

            Text("위로 스와이프해서 종료하기")
                .footNote()
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Spacer(minLength: 16)
        }
        .frame(height: 250) // 날짜/추가하기 줄 가려지도록
        .frame(maxWidth: .infinity)
        .background(
            Color("Primary")
                .matchedGeometryEffect(id: "container", in: ns)
                .ignoresSafeArea(edges: .top)
        )
        .cornerRadius(28, corners: [.bottomLeft, .bottomRight])
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
        .offset(y: dragYOffset.wrappedValue)
        .contentShape(Rectangle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { v in
                    if v.translation.height < 0 {
                        dragYOffset.wrappedValue = max(-20, v.translation.height / 4)
                    } else {
                        dragYOffset.wrappedValue = 0
                    }
                }
                .onEnded { v in
                    defer { withAnimation(.spring(response: 0.25)) { dragYOffset.wrappedValue = 0 } }
                    if v.translation.height < -80 { swipeUpToFinish() } // 위로 스와이프 종료
                }
        )
    }

    // MARK: - 액션들
    func startTimer(for routine: Routine) {
        timerValue = 0
        timerRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in timerValue += 1 }
        activeRoutine = routine
        overlayDocked = false
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { showTimerOverlay = true }
    }

    func pauseOrResumeFromOverlay() {
        if timerRunning {
            timer?.invalidate(); timerRunning = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                showTimerOverlay = false
                overlayDocked = true
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in timerValue += 1 }
            timerRunning = true
        }
    }

    func toggleFromDock() {
        if timerRunning {
            timer?.invalidate(); timerRunning = false
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in timerValue += 1 }
            timerRunning = true
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                overlayDocked = false
                showTimerOverlay = true
            }
        }
    }

    func finishFromDock() {
        elapsedSnapshot = timerValue
        endTimer()
        withAnimation(.easeInOut(duration: 0.25)) {
            overlayDocked = false
            showTimerOverlay = false
        }
        showCompletionModal = true
    }

    func endTimer() {
        if let r = activeRoutine,
           let idx = vm.routines.firstIndex(where: { $0.id == r.id }) {
            vm.routines[idx].elapsedTime += timerValue
        }
        timer?.invalidate(); timer = nil
        timerValue = 0
        timerRunning = false
    }

    func timerString(from t: TimeInterval) -> String {
        let h = Int(t) / 3600, m = Int(t) % 3600 / 60, s = Int(t) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: - Safe Area helper
private extension UIApplication {
    var topSafeArea: CGFloat {
        (connectedScenes.first as? UIWindowScene)?
            .keyWindow?.safeAreaInsets.top ?? 0
    }
    var bottomSafeArea: CGFloat {
        (connectedScenes.first as? UIWindowScene)?
            .keyWindow?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - Preview
#Preview {
    MainView()
        .environmentObject(SessionStore())
}
