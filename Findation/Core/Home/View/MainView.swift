import SwiftUI
import UIKit

struct MainView: View {
    @State private var currentDate = Date()
    @State private var activeRoutines: [Routine] = []
    @State private var completedRoutines: [Routine] = []

    @State private var showAddTask = false
    @State private var editTargetRoutine: Routine? = nil
    @State private var activeRoutine: Routine? = nil

    @State private var showTimerOverlay = false
    @State private var timerValue: TimeInterval = 0
    @State private var timerRunning = false
    @State private var timer: Timer? = nil
    @State private var dragOffset: CGFloat = 0

    @State private var showDeleteConfirmation = false
    @State private var routineToDelete: Routine? = nil

    @State private var showCompletionModal = false
    @State private var showAllRoutines = false

    var body: some View {
        ZStack {
            Color("Secondary").ignoresSafeArea()

            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        VStack(spacing: 0) {
                            HeaderSection(date: currentDate, showAddTask: $showAddTask)

                            let visibleActive = showAllRoutines ? activeRoutines : Array(activeRoutines.prefix(5))
                            let combinedRoutines = visibleActive + completedRoutines

                            VStack(spacing: 0) {
                                UIKitRoutineListView(
                                    routines: .constant(combinedRoutines),
                                    onLongPressComplete: { routine in
                                        guard !routine.isCompleted else { return }
                                        startTimer(for: routine)
                                    },
                                    onEdit: { routine in
                                        editRoutine(routine)
                                    },
                                    onDelete: { routine in
                                        routineToDelete = routine
                                        showDeleteConfirmation = true
                                    },
                                    onComplete: { routine in
                                        activeRoutine = routine
                                        showCompletionModal = true

                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            if let last = combinedRoutines.last {
                                                scrollProxy.scrollTo(last.id, anchor: .bottom)
                                            }
                                        }
                                    }
                                )
                                .frame(height: CGFloat(combinedRoutines.count * 56))

                                if activeRoutines.count > 5 {
                                    Button(action: {
                                        withAnimation {
                                            showAllRoutines.toggle()
                                        }
                                    }) {
                                        Image(systemName: showAllRoutines ? "chevron.up" : "chevron.down")
                                            .foregroundColor(Color("Primary"))
                                            .padding(.vertical, 12)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                        .background(Color.white)
                        .cornerRadius(32, corners: [.bottomLeft, .bottomRight])

                        StatSection()
                        ExploreSection()
                    }
                }
            }

            if let routine = activeRoutine, showTimerOverlay {
                timerOverlay(for: routine)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showAddTask) {
            AddTaskView(
                activeRoutines: $activeRoutines,
                completedRoutines: $completedRoutines,
                routineToEdit: .constant(nil)
            )
        }
        .sheet(item: $editTargetRoutine) { routine in
            AddTaskView(
                activeRoutines: $activeRoutines,
                completedRoutines: $completedRoutines,
                routineToEdit: $editTargetRoutine
            )
        }
        .fullScreenCover(isPresented: $showCompletionModal) {
            if let routine = activeRoutine {
                CompletionConfirmationView(
                    routineTitle: routine.title,
                    elapsedTime: routine.elapsedTime,
                    onComplete: {
                        completeRoutine(routine)
                        resetOverlay()
                    },
                    onPhotoProof: {
                        completeRoutine(routine)
                        resetOverlay()
                    },
                    onDismiss: { resetOverlay() }
                )
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("정말 삭제하시겠어요?"),
                message: Text("이 루틴은 삭제 후 복구할 수 없습니다."),
                primaryButton: .destructive(Text("삭제")) {
                    deleteRoutine()
                },
                secondaryButton: .cancel {
                    routineToDelete = nil
                }
            )
        }
        .onDisappear { timer?.invalidate() }
    }

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
                        Text("세이님,")
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
                        if value.translation.height < -150 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = -geo.size.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showTimerOverlay = false
                                dragOffset = 0
                                endTimer()
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
           let index = activeRoutines.firstIndex(where: { $0.id == routine.id }) {
            activeRoutines[index].elapsedTime += timerValue
        }

        timer?.invalidate()
        timer = nil
        timerValue = 0
        timerRunning = false
    }

    func resetOverlay() {
        showCompletionModal = false
        activeRoutine = nil
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

    func completeRoutine(_ routine: Routine) {
        if let index = activeRoutines.firstIndex(where: { $0.id == routine.id }) {
            var completed = activeRoutines.remove(at: index)
            completed.isCompleted = true
            completedRoutines.append(completed)
        }
    }

    func deleteRoutine() {
        if let routine = routineToDelete {
            activeRoutines.removeAll { $0.id == routine.id }
            completedRoutines.removeAll { $0.id == routine.id }
            routineToDelete = nil
        }
    }
}
