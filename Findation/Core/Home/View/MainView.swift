//
//  MainView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var vm = RoutinesViewModel()

    // 바인딩 필요 시:
    private var routinesBinding: Binding<[Routine]> {
        Binding(get: { vm.routines }, set: { vm.routines = $0 })
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
                Color.white.ignoresSafeArea()
                
                if vm.isLoading {
                    ProgressView()
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                HeaderSection(date: currentDate, nickname: nickname, showAddTask: $showAddTask)
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)

                                UIKitRoutineListView(
                                    routines: routinesBinding,
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
                                        completeRoutine(routine)
                                        activeRoutine = routine
                                        showCompletionModal = true

                                        // 루틴 아래로 이동 후 scroll
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            if let last = vm.routines.last {
                                                scrollProxy.scrollTo(last.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                )
                                .frame(height: CGFloat(vm.routines.count * 56) + (vm.routines.count > 5 ? 40 : 0))
                                .padding(.bottom, 20)

                                StatSection()
                                    .padding(.bottom, 30)

                                ExploreSection()
                                    .padding(.bottom, 40)
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
                    LastModalView(title: routine.title,proofImage: proofImage, showLastModal: $showLastModal)
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
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar) //네비게이션 스택
            .task { // 최초 진입 1회 페치
                await vm.load()
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker { image in
                    self.proofImage = image
                }
            }
            .refreshable { // 당겨서 새로고침
                await vm.load()
            }
            .sheet(isPresented: $showAddTask, onDismiss: {
                Task { await vm.load() }
            }) {
                AddTaskView(routines: routinesBinding, routineToEdit: $editTargetRoutine)
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

        }
    }

    func startTimer(for routine: Routine) {
        activeRoutine = routine
        timerValue = 0
        timerRunning = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timerValue += 1
        }

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
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(nickname)님")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("오늘도 힘내요!")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: pauseOrResumeTimer) {
                        Image(systemName: timerRunning ? "pause.fill" : "play.fill")
                            .foregroundColor(.blue)
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .frame(width: 260, height: 260)

                    VStack(spacing: 12) {
                        Text(routine.title)
                            .foregroundColor(.white)
                            .font(.system(size: 16))

                        Text(timerString(from: timerValue))
                            .foregroundColor(.white)
                            .font(.system(size: 36, weight: .semibold, design: .monospaced))
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Text("위로 스와이프해서 종료하기")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.footnote)
                }
                .padding(.bottom, 40)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color.blue)
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
                            withAnimation(.easeInOut(duration: 0.35)) {
                                dragOffset = -geo.size.height
                            }
                            // 스냅샷 먼저 저장
                            elapsedSnapshot = timerValue

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
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
