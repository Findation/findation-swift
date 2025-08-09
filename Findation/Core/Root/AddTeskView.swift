//
//  AddTeskView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var routines: [Routine]
    @Binding var routineToEdit: Routine?

    @State private var taskText: String = ""
    @State private var categoryText: String = ""
    @FocusState private var isFocusedTask: Bool
    @FocusState private var isFocusedCategory: Bool

    @State private var repeatWeekly: Bool = false
    @State private var selectedDays: [Bool] = Array(repeating: false, count: 7)
    
    func normalizeCategory() {
        let trimmed = categoryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if trimmed.hasPrefix("#") {
            let noHash = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
            categoryText = "# " + noHash
        } else {
            categoryText = "# " + trimmed
        }
    }
    
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
                        if routineToEdit == nil {
                            RoutineAPI.postRoutine(title: taskText, category: categoryText, weekdays: selectedDays) { result in
                                switch result {
                                case .success:
                                    // 루틴 등록 성공
                                    print("ADD ROUTINE SUCCESS")
                                case .failure:
                                    // 루틴 등록 실패
                                    print("ADD ROUTINE FAILED")
                                }
                            }
                        } else {
                            RoutineAPI.patchRoutine(id: routineToEdit!.id, title: taskText, category: categoryText, is_repeated: calculateIsRepeatedBitmask(selectedDays)) { result in
                                switch result {
                                case .success:
                                    // 루틴 수정 성공
                                    print("PATCH ROUTINE SUCCESS")
                                case .failure:
                                    // 루틴 등록 실패
                                    print("PATCH ROUTINE FAILED")
                                }
                            }
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
                .onChange(of: isFocusedCategory) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        normalizeCategory()
                    }
                }

            // MARK: - 루틴 텍스트 입력
            TextField("할 일을 입력하세요.", text: $taskText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
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

            // MARK: - 요일 선택
            HStack {
                ForEach(DATES.indices, id: \.self) { index in
                    Text(DATES[index])
                        .font(.body)
                        .frame(width: 45, height: 28)
                        .background(
                            selectedDays[index] ? Color.blue : Color.white
                        )
                        .foregroundColor(
                            selectedDays[index] ? Color.white : Color.blue
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 999)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .cornerRadius(999)
                        .onTapGesture {
                            selectedDays[index].toggle()
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
                categoryText = editing.category
                selectedDays = decodeIsRepeatedBitmask(editing.isRepeated)
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


