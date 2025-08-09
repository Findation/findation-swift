import Foundation

struct Routine: Identifiable, Equatable, Codable {
    // 서버 필드
    let id: String           // 서버에서 문자열 UUID
    let title: String
    let category: String
    let isRepeated: Int      // is_repeated
    let createdAt: Date      // created_at (아래 커스텀 디코더로 파싱)
    let user: String         // 문자열 UUID

    // 로컬 UI 상태
    var elapsedTime: TimeInterval = 0
    var isCompleted: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, title, category, user
        case isRepeated = "is_repeated"
        case createdAt  = "created_at"
    }
}

extension Routine {
    var isRepeatedBitmask: Int { self.isRepeated }

    func matches(date: Date, calendar: Calendar = .current) -> Bool {
        return isScheduledOnDate(bitmask: isRepeatedBitmask, date: date, calendar: calendar)
    }
}
