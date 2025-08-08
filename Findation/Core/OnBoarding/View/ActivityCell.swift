//
//  ActivityCell.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import SwiftUI

struct ActivityCell: View {
    @Binding var selectedActivities: Set<String>
    @Binding var activeActivityID: UUID?
    @Binding var showError: Bool
    
    let activity: Activity
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 6) {
                ZStack {
                    if let imageName = activity.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 102, height: 102)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 102, height: 102)
                    }

                    Circle()
                        .stroke(
                            selectedActivities.contains(activity.name)
                            ? Color(Color.accentColor)
                            : Color(Color.lightGrayColor),
                            lineWidth: 2
                        )
                        .frame(width: 105, height: 105)

                    if selectedActivities.contains(activity.name) {
                        Circle()
                            .fill(Color(Color.primaryColor).opacity(0.4))
                            .frame(width: 105, height: 105)

                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                }

                Text(activity.name)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if activeActivityID == activity.id {
                Rectangle()
                    .fill(Color(Color.lightGrayColor))
                    .frame(height: 105)
                    .cornerRadius(12)
                    .opacity(0.6)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: activeActivityID)
            }
        }
        .onTapGesture {
            if selectedActivities.contains(activity.name) {
                selectedActivities.remove(activity.name)
            } else {
                selectedActivities.insert(activity.name)
            }
            showError = false
        }
        .onLongPressGesture {
            activeActivityID = activity.id
        }
    }
}
//
//#Preview {
//    ActivityCell()
//}
