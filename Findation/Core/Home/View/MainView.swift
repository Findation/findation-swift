import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var vm = RoutinesViewModel()
    
    @State private var showAllRoutines = false
    // 바인딩 필요 시:
    private var routinesBinding: Binding<[Routine]> {
        Binding(get: { vm.routines }, set: { vm.routines = $0 })
    }
    private var todaysRoutines: [Routine] {
        vm.routines.filter { $0.matches(date: currentDate) }
    }
    private var visibleRoutines: [Routine] {
        showAllRoutines ? todaysRoutines : Array(todaysRoutines.prefix(5))
    }
    private var todaysBinding: Binding<[Routine]> {
        Binding(
            get:{visibleRoutines },
            set: { _ in /* no-op: 개별 액션(onEdit/onDelete 등)에서 원본 vm.routines를 갱신하므로 여기선 불필요 */ }
        )
    }
    let nickname = KeychainHelper.load(forKey: "nickname") ?? "어푸"
    
    @State private var currentDate = Date()
      
    @State private var showAddTask = false
    @State private var editTargetRoutine: Routine? = nil
    @State private var showCompletionConfirmaion: Bool = false

    @State private var activeRoutine: Routine? = nil

    @State private var showTimerOverlay = false
    @State private var timerValue: TimeInterval = 0
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var dragOffset: CGFloat = 0

    @State private var showDeleteConfirmation = false
    @State private var routineToDelete: Routine? = nil

    @State private var showCompletionModal = false

    @State private var showLastModal = false
    @State private var elapsedSnapshot: TimeInterval = 0
    
    @State private var showCamera = false
    @State private var proofImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Secondary").ignoresSafeArea()
                
                if vm.isLoading {
                    ProgressView()
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(spacing:0) {
                                    HeaderSection(date: currentDate, nickname: nickname, showAddTask: $showAddTask)
                                        .padding(.horizontal)
                                    VStack(spacing: 0) {
                                        UIKitRoutineListView(
                                            routines: todaysBinding,
                                            onLongPressComplete: { routine in
                                                guard !routine.isCompleted else { return }
                                                startTimer(for: routine)
                                            },
                                            onEdit: { routine in
                                                editRoutine(routine)
                                                showAddTask = true
                                            },
                                            onDelete: { routine in
                                                routineToDelete = routine
                                                showDeleteConfirmation = true
                                                RoutineAPI.deleteRoutine(id: routine.id) { success in
                                                    if success {
                                                        if let index = vm.routines.firstIndex(where: { $0.id == routine.id }) {
                                                            vm.routines.remove(at: index)
                                                        }
                                                    } else {
                                                        // 루틴 삭제 실패 로직
                                                    }
                                                }
                                            },
                                            onComplete: { routine in
                                                Task {
                                                    await MainActor.run {
                                                        vm.markCompleted(routine.id)
                                                    }
                                                }
                                                activeRoutine = routine
                                                showCompletionModal = true
                                                
                                                // 루틴 아래로 이동 후 scroll
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    if let last = todaysRoutines.last ?? vm.routines.last {
                                                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                                                    }
                                                }
                                            }
                                        )
                                        .frame(height: 54 * CGFloat(visibleRoutines.count))
                                        
                                        if todaysRoutines.count > 5 {
                                            Button(action: {
                                                showAllRoutines.toggle()
                                            }) {
                                                Image(systemName: showAllRoutines ? "chevron.up" : "chevron.down")
                                                    .foregroundColor(Color(Color.primaryColor))
                                                    .padding(12)
                                                    .background(
                                                        Circle()
                                                            .fill(Color(hex: "#EDF5FC"))
                                                    )
                                            }
                                            .padding(.top, 12)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 20)
                                }
                                .background(Color.white)
                                .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
                                .shadow(color: Color(hex: "A2C6FF"), radius: 5, x: 0, y: 1)
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                StatSection()
                 
                                Spacer()
                                    .frame(height: 20)
                                
                                ExploreSection()
                                
                                Spacer()
                                    .frame(height: 90)
                            }
                        }
                    }
                }
                
                if showCompletionModal, let routine = activeRoutine {
                    CompletionConfirmationView(
                        routineTitle: routine.title,
                        elapsedTime: elapsedSnapshot,
                        onComplete: { /* 완료 처리 */ },
                        onPhotoProof: {
                            showCamera = true
                            showCompletionModal = false
                            showLastModal = true
                        },
                        onDismiss: { showCompletionModal = false }
                    )
                }
                
                if showLastModal, let proofImage = proofImage, let routine = activeRoutine {
                    LastModalView(title: routine.title,proofImage: proofImage, showLastModal: $showLastModal) {
                        Task {
                            await MainActor.run {
                                vm.markCompleted(routine.id)
                            }
                        }
                    }
                }
                
                if let routine = activeRoutine {
                                    ZStack {
                                        Color.black.opacity(showTimerOverlay ? 0.5 : 0)
                                            .ignoresSafeArea()
                                            .animation(.easeInOut(duration: 0.4), value: showTimerOverlay)

                                        if showTimerOverlay {
                                            timerOverlay(for: routine)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                                .zIndex(1)
                                        }
                                    }
                                    .zIndex(1)
                                }
                            } // ⬅️ 여기까지가 ZStack 본문
                            // ⬇️ 이 모디파이어들은 "바로 위 ZStack"에 붙는다
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
                                ZStack {
                                    Color.black.ignoresSafeArea()
                                    CameraPicker { image in
                                        self.proofImage = image
                                    }
                                }
                            }
                            .refreshable {
                                await vm.load()
                            }
                            .sheet(isPresented: $showAddTask, onDismiss: {
                                Task { await vm.load() }
                            }) {
                                // ⬇️ AddTaskView가 (routines:, routineToEdit:) 시그니처인지 확인!
                                AddTaskView(
                                    routines: routinesBinding,
                                    routineToEdit: $editTargetRoutine
                                )
                                    .id(editTargetRoutine?.id)
                            }
                            .alert(isPresented: $showDeleteConfirmation) {
                                Alert(
                                    title: Text("정말 삭제하시겠어요?"),
                                    message: Text("이 루틴은 삭제 후 복구할 수 없습니다."),
                                    primaryButton: .destructive(Text("삭제")) {
                                        if let routine = routineToDelete {
                                            vm.routines.removeAll { $0.id == routine.id }
                                            routineToDelete = nil
                                        }
                                    },
                                    secondaryButton: .cancel {
                                        routineToDelete = nil
                                    }
                                )
                            }
                            .onDisappear {
                                timer?.invalidate()
                            }
                        } // ⬅️ 여기서 NavigationStack 끝
                    } // ⬅️ body ViewBuilder 끝

    // MARK: - 타이머 로직
    func startTimer(for routine: Routine) {
        timerValue = 0
        timerRunning = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerValue += 1
        }

        activeRoutine = routine

        withAnimation(.easeInOut(duration: 0.5)) {
            showTimerOverlay = true
        }
    }

    func pauseOrResumeTimer() {
        if timerRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                timerValue += 1
            }
        }
        timerRunning.toggle()
    }

    func timerOverlay(for routine: Routine) -> some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Button(action: pauseOrResumeTimer) {
                            Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                                .foregroundColor(.blue)
                                .frame(width: 50, height: 50)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }

                    VStack(spacing: 4) {
                        Text("\(nickname)님")
                        Text("오늘도 힘내요!")
                    }
                    .title1()
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.top, 80)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 310, height: 310)

                    VStack(spacing: 12) {
                        Text(routine.title)
                            .bodytext()
                            .foregroundColor(.white)

                        Text(timerString(from: timerValue))
                            .timeLarge()
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                VStack(spacing: 30) {
                    Image("swipe")
                        .resizable()
                        .frame(width: 22, height: 32)

                    Text("위로 스와이프해서 종료하기")
                        .footNote()
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 88)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color("Primary"))
            .cornerRadius(32, corners: [.bottomLeft, .bottomRight])
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height < 0 {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        // ❌ 여기서 바로 모달 띄우지 말자
                        if value.translation.height < -150 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = -geo.size.height
                            }
                            elapsedSnapshot = timerValue
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showTimerOverlay = false
                                dragOffset = 0
                                endTimer()                // 여기서 timerValue가 0으로 초기화돼도 OK(이미 스냅샷 있음)
                                showCompletionModal = true // 이제 모달 오픈
                            }
                        } else {
                            withAnimation {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }

    func endTimer() {
        if let routine = activeRoutine,
           let index = vm.routines.firstIndex(where: { $0.id == routine.id }) {
            vm.routines[index].elapsedTime += timerValue
        }
        timer?.invalidate()
        timer = nil
        timerValue = 0
        timerRunning = false
    }

    func completeRoutine(_ routine: Routine) {
        if let index = vm.routines.firstIndex(where: { $0.id == routine.id }) {
            vm.routines[index].isCompleted = true
            let completed = vm.routines.remove(at: index)
            vm.routines.append(completed)
        }
    }

    func timerString(from time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = Int(time) % 3600 / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    func editRoutine(_ routine: Routine) {
        editTargetRoutine = routine
    }
}

#Preview {
    MainView()
}
