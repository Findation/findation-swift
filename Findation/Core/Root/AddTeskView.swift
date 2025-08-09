import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var activeRoutines: [Routine]
    @Binding var completedRoutines: [Routine]
    @Binding var routineToEdit: Routine?

    @State private var taskText: String = ""
    @State private var categoryText: String = ""
    @FocusState private var isFocusedTask: Bool
    @FocusState private var isFocusedCategory: Bool

    @State private var repeatWeekly: Bool = false
    @State private var selectedDays: [String] = []
    let days = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        VStack {
            // MARK: - 상단 헤더
            ZStack {
                Text(routineToEdit == nil ? "루틴 추가" : "루틴 수정")
                    .font(.system(size: 24, weight: .bold))

                HStack {
                    Button("취소") {
                        dismiss()
                    }

                    Spacer()

                    Button("완료") {
                        let trimmedTitle = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedTag = categoryText.trimmingCharacters(in: .whitespacesAndNewlines)

                        if var editing = routineToEdit {
                            if let index = activeRoutines.firstIndex(where: { $0.id == editing.id }) {
                                activeRoutines[index].title = trimmedTitle
                                activeRoutines[index].tag = trimmedTag
                            } else if let index = completedRoutines.firstIndex(where: { $0.id == editing.id }) {
                                completedRoutines[index].title = trimmedTitle
                                completedRoutines[index].tag = trimmedTag
                            }
                        } else {
                            activeRoutines.append(Routine(title: trimmedTitle, tag: trimmedTag))
                        }

                        dismiss()
                    }
                    .disabled(taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || categoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(
                        taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || categoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue
                    )
                }
                .padding(.horizontal, 20)
            }

            // MARK: - 카테고리 입력
            TextField("# 카테고리를 입력하세요.", text: $categoryText)
                .foregroundColor(.blue)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .focused($isFocusedCategory)
                .onChange(of: categoryText) {
                    if !categoryText.hasPrefix("#") {
                        categoryText = "# " + categoryText.replacingOccurrences(of: "# ", with: "")
                    }
                }

            // MARK: - 루틴 텍스트 입력
            TextField("할 일을 입력하세요.", text: $taskText)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .focused($isFocusedTask)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 20),
                    alignment: .bottom
                )
                .task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    isFocusedTask = true
                }

            // MARK: - 반복 옵션
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(repeatWeekly ? Color.blue : Color.gray, lineWidth: 1)
                        .frame(width: 20, height: 22)
                        .background(repeatWeekly ? Color.white : Color.clear)
                        .cornerRadius(4)

                    if repeatWeekly {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .onTapGesture {
                    repeatWeekly.toggle()
                }

                Text("매주 반복할래요")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        repeatWeekly.toggle()
                    }

                Spacer()
            }
            .padding(.vertical, 20)
            .padding(.leading, 20)

            // MARK: - 요일 선택
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.body)
                        .frame(width: 45, height: 28)
                        .background(
                            selectedDays.contains(day) ? Color.blue : Color.white
                        )
                        .foregroundColor(
                            selectedDays.contains(day) ? Color.white : Color.blue
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .cornerRadius(999)
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.removeAll { $0 == day }
                            } else {
                                selectedDays.append(day)
                            }
                        }
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top , 20)
        .background(Color.white)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            if let editing = routineToEdit {
                taskText = editing.title
                categoryText = editing.tag
            }
        }
    }
}

// 키보드 내리기 확장
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
