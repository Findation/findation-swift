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
        }
    }
}

#Preview {
    BottomSheet2View()
}
