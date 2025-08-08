import SwiftUI

struct PasswordStrengthBar: View {
    let strength: Int
    
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Rectangle()
                    .frame(width: 30,height: 6)
                    .foregroundColor(
                        index < strength
                        ? Color(Color.primaryColor)
                        : Color(Color.primaryColor.opacity(0.3))
                    )
                    .cornerRadius(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: strength)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}
