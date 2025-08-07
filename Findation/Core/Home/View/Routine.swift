import Foundation

struct Routine: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var tag: String
    var elapsedTime: TimeInterval = 0
    var isCompleted: Bool = false
}
