import SwiftUI

// MARK: - Demo 모델 (백엔드 연결 전)
struct BackendPhoto: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let imageURL: URL
}

struct DaySheetModel: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let photos: [BackendPhoto]
}

struct CollectedChangeView: View {
    // MARK: State
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var sheetModel: DaySheetModel? = nil

    @State private var photosByDay: [Date: [BackendPhoto]] = [:]
    @State private var selectedDayPhotos: [BackendPhoto] = []
    @State private var currentPhotoIndex: Int = 0

    // 사진은 없지만 ‘활동은 한’ 날(used_time > 0)
    @State private var activityDoneDays: Set<Date> = []

    // 로딩/에러
    @State private var isLoading = false
    @State private var loadError: String?

    // MARK: Calendar Utils
    private let calendar = Calendar.current
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]

    struct CalendarHelper {
        static func currentMonthText(from date: Date) -> String {
            let f = DateFormatter()
            f.locale = Locale(identifier: "ko_KR")
            f.dateFormat = "M월"
            return f.string(from: date)
        }
        static func daysInMonth(for date: Date, calendar: Calendar = .current) -> Int {
            calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        }
        static func firstWeekdayOffset(for date: Date, calendar: Calendar = .current) -> Int {
            let comps = calendar.dateComponents([.year, .month], from: date)
            guard let first = calendar.date(from: comps) else { return 0 }
            let weekday = calendar.component(.weekday, from: first) // 1:일~7:토
            return (weekday + 5) % 7 // 월=0 시작으로 보정
        }
    }

    // 서버와 날짜 포맷 맞추는 포매터 (YYYY-MM-DD)
    private let backendDF: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    // MARK: Helpers
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    private func TodayDate() { currentDate = Date() }

    private func dateFor(day: Int) -> Date? {
        var comps = calendar.dateComponents([.year, .month], from: currentDate)
        comps.day = day
        return calendar.date(from: comps)
    }
    private func isToday(day: Int) -> Bool {
        guard let d = dateFor(day: day) else { return false }
        return calendar.isDate(d, inSameDayAs: Date())
    }
    private func isPast(day: Int) -> Bool {
        guard let d = dateFor(day: day) else { return false }
        return calendar.compare(d, to: Date(), toGranularity: .day) == .orderedAscending
    }
    private func isPastOrToday(day: Int) -> Bool {
        guard let d = dateFor(day: day) else { return false }
        let cmp = calendar.compare(d, to: Date(), toGranularity: .day)
        return cmp == .orderedAscending || cmp == .orderedSame
    }
    private func dayKey(for day: Int) -> Date? {
        guard let d = dateFor(day: day) else { return nil }
        return calendar.startOfDay(for: d)
    }
    private func firstPhoto(of day: Int) -> BackendPhoto? {
        guard let key = dayKey(for: day) else { return nil }
        return photosByDay[key]?.first
    }

    // 해당 월의 1일~말일
    private func monthRange(for date: Date) -> (start: Date, end: Date)? {
        if let interval = calendar.dateInterval(of: .month, for: date) {
            let end = calendar.date(byAdding: DateComponents(day: -1), to: interval.end)!
            return (start: calendar.startOfDay(for: interval.start), end: calendar.startOfDay(for: end))
        }
        return nil
    }

    // 달 변경 시 데이터 패칭
    private func fetchMonth(date: Date) {
        guard let (start, end) = monthRange(for: date) else { return }
        isLoading = true
        loadError = nil

        Task {
            do {
                let items = try await UsedTimeAPI.getUsedTimeByStartEndData(startDate: start, endDate: end)

                var grouped: [Date: [BackendPhoto]] = [:]
                var activeDays = Set<Date>()

                for item in items {
                    let key = calendar.startOfDay(for: item.date)

                    if !item.images.isEmpty {
                        let photos = item.images.enumerated().map { idx, url in
                            BackendPhoto(
                                date: key.addingTimeInterval(TimeInterval(idx)),
                                imageURL: url
                            )
                        }
                        grouped[key, default: []].append(contentsOf: photos)
                    }

                    if item.usedTime > 0 {
                        activeDays.insert(key)
                    }
                }

                await MainActor.run {
                    self.photosByDay = grouped
                    self.activityDoneDays = activeDays
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.loadError = error.localizedDescription
                }
            }
        }
    }

    // 현재 보이는 달을 식별하는 키 (연-월)
    private var monthKey: String {
        let comps = calendar.dateComponents([.year, .month], from: currentDate)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)"
    }

    // MARK: View
    var body: some View {
        let offset = CalendarHelper.firstWeekdayOffset(for: currentDate)
        let days = CalendarHelper.daysInMonth(for: currentDate)
        let totalCells = offset + days
        let numRows = Int(ceil(Double(totalCells) / 7.0))
        
        VStack(spacing: 0) {
            ZStack {
                    // 1. '< 8월 >' 그룹을 중앙에 배치
                    HStack {
                        Spacer() // 왼쪽 Spacer
                        HStack(spacing: 15) {
                            Button { changeMonth(by: -1) } label: {
                                Image(systemName: "arrowtriangle.left.fill")
                                    .foregroundStyle(Color("Primary"))
                            }
                            Text(CalendarHelper.currentMonthText(from: currentDate))
                                .bodytext()
                                .foregroundColor(Color("Black"))
                                .frame(minWidth: 60) // 텍스트 너비 고정
                            Button { changeMonth(by: 1) } label: {
                                Image(systemName: "arrowtriangle.right.fill")
                                    .foregroundStyle(Color("Primary"))
                            }
                        }
                        Spacer() // 오른쪽 Spacer
                    }

                    // 2. '오늘' 버튼을 오른쪽에 배치 (ZStack 내에서 별도 H스택 사용)
                    HStack {
                        Spacer() // 왼쪽의 모든 공간을 차지하여 '오늘' 버튼을 오른쪽으로 밀어냅니다.
                        Button { TodayDate() } label: {
                            Text("오늘")
                                .caption1()
                                .foregroundColor(Color("Primary"))
                                .frame(width: 40, height: 22)
                                .background(Color("Secondary"))
                                .cornerRadius(11)
                        }
                    }
                }
                .padding(.horizontal, 16) // ZStack 전체의 좌우 패딩
                .padding(.top, 17)
                .padding(.bottom, 12)
            
            // 요일 & 날짜
            GeometryReader { geo in
                let horizontalInset: CGFloat = 16
                let spacing: CGFloat = 8
                let innerWidth = geo.size.width - horizontalInset * 2
                let dot = floor((innerWidth - spacing * 6) / 7) // 7열 + 6간격
                
                // 요일
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(dot), spacing: spacing), count: 7),
                    spacing: 0
                ) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .caption2()
                            .foregroundColor(Color("DarkGray"))
                            .frame(width: dot, height: 22)
                    }
                }
                .padding(.horizontal, horizontalInset)
                
                // 여백
                VStack { Spacer().frame(height: 6) }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 날짜
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(dot), spacing: spacing), count: 7),
                    spacing: spacing
                ) {
                    ForEach(0..<(offset + days), id: \.self) { index in
                        if index < offset {
                            Color.clear.frame(width: dot, height: dot)
                        } else {
                            let day = index - offset + 1
                            let selectable = isPastOrToday(day: day)
                            let todayFlag = isToday(day: day)
                            let key = dayKey(for: day)
                            
                            ZStack {
                                if selectable {
                                    if let first = firstPhoto(of: day) {
                                        // 사진 O → 썸네일
                                        AsyncImage(url: first.imageURL) { phase in
                                            switch phase {
                                            case .success(let img):
                                                img.resizable()
                                                    .scaledToFill()
                                                    .frame(width: dot, height: dot)
                                                    .clipped()
                                                    .opacity(0.7)
                                            case .failure(_):
                                                Color(Color.primaryColor)
                                            case .empty:
                                                Color.gray.opacity(0.15)
                                            @unknown default:
                                                Color(Color.primaryColor)
                                            }
                                        }
                                        .clipShape(Circle())
                                    } else if let k = key, activityDoneDays.contains(k) {
                                        // 활동 O & 사진 X → 파란색
                                        Color(Color.primaryColor)
                                            .frame(width: dot, height: dot)
                                            .clipShape(Circle())
                                    } else {
                                        // 활동 X → 회색
                                        Color.gray.opacity(0.3)
                                            .frame(width: dot, height: dot)
                                            .clipShape(Circle())
                                    }
                                } else {
                                    // 미래 → 회색
                                    Color.gray.opacity(0.3)
                                        .frame(width: dot, height: dot)
                                        .clipShape(Circle())
                                }
                                Text("\(day)").foregroundColor(.white)
                                // Text("\(day)").foregroundColor(let image == nil ? Color.white : Color.primaryColor)
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: dot, height: dot)
                                    .opacity(todayFlag ? 1 : 0)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectable, let k = key {
                                    selectedDate = k
                                    let all = photosByDay[k] ?? []
                                    let filtered = all.filter { $0.imageURL.lastPathComponent.lowercased() != "default.png" }
                                    currentPhotoIndex = 0
                                    sheetModel = DaySheetModel(date: k, photos: filtered)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalInset)
                .padding(.top, 28)
                .padding(.bottom, 15)
            }
            .frame(height: (numRows == 6 ? 234 : 214))
            
            Spacer(minLength: 0)
        }
        .frame(width: 353, height: numRows == 6 ? 390 : 350, alignment: .top)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color("Primary"), radius: 4, x: 0, y: 2)
        
        // 달 바뀔 때마다 자동 패칭
        .task(id: monthKey) {
            fetchMonth(date: currentDate)
        }
        
        // 로딩/에러 오버레이(선택)
        .overlay {
            if isLoading {
                ZStack { Color.black.opacity(0.05).ignoresSafeArea(); ProgressView() }
            } else if let err = loadError {
                VStack { Spacer(); Text(err).foregroundColor(.red).padding(.bottom, 8) }
            }
        }
        
        // 사진 보기 시트
        .sheet(item: $sheetModel) { model in
            PhotoSheetView(
                date: model.date,
                photos: model.photos,
                currentIndex: $currentPhotoIndex
            ) { sheetModel = nil }
                .presentationDetents([.height(420), .medium])
        }
    }
}

// MARK: - Photo Sheet
fileprivate struct PhotoSheetView: View {
    let date: Date
    let photos: [BackendPhoto]
    @Binding var currentIndex: Int
    var onClose: () -> Void

    private let pillFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 (E)"
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            Text(pillFormatter.string(from: date))
                .font(.headline)

            if photos.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.gray.opacity(0.08))
                    .frame(height: 260)
                    .overlay(
                        Text("이 날은 저장된 사진이 없습니다.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    )
                    .padding(.horizontal)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(photos.indices, id: \.self) { i in
                        AsyncImage(url: photos[i].imageURL) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 260)
                                    .tag(i)
                            case .failure(_):
                                Color.gray.opacity(0.15)
                                    .frame(height: 260)
                                    .overlay(Text("이미지 불러오기 실패").foregroundColor(.secondary))
                                    .tag(i)
                            case .empty:
                                ZStack { Color.gray.opacity(0.08); ProgressView() }
                                    .frame(height: 260)
                                    .tag(i)
                            @unknown default:
                                Color.gray.opacity(0.15).frame(height: 260).tag(i)
                            }
                        }
                    }
                }
                .frame(height: 260)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .padding(.horizontal)
            }

            Button("닫기") { onClose() }
                .padding(.top, 4)
        }
        .padding()
    }
}

#Preview {
    CollectedChangeView()
}
