//
//  BottomSheet2.swift
//  Findation
//
//  Created by 박수혜 on 8/5/25.
//
import SwiftUI
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct BottomSheet2View: View {
    @State private var isSheetPresented = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            Button { isSheetPresented = true
            } label: {
                Text(" + 추가하기")
                    .padding()
                    .font(.system(size: 15))
                    .font(.subheadline)
                    .frame(maxWidth: 150)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(50)
            }
            
            .sheet(isPresented: $isSheetPresented) {
                RoutineSheetView()
            }
        }
    }
}

struct RoutineSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var taskText: String = ""
    @FocusState private var isFocused: Bool
    @State private var repeatWeekly: Bool = false
    @State private var selectedDays: [String] = []
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    @State private var categoryText: String = ""
    @FocusState private var isFocusedCategory: Bool
    
    
    var body: some View {
        
        VStack{
            ZStack{
                Text("루틴 추가")
                    .font(.system(size: 24, weight: .bold))
                
                HStack{
                    Spacer()
                    Button("완료") {
                        dismiss()
                        
                    }
                    .disabled(taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(taskText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
                
                .padding(20)
                
            }
            
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
            
            TextField("할 일을 입력하세요.",text: $taskText)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .focused($isFocused)
                .overlay(
                    HStack{
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                        .padding(.horizontal, 20),
                    alignment: .bottom
                )
            
                .task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    isFocused = true
                }
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
    }
}

#Preview {
    BottomSheet2View()
}
