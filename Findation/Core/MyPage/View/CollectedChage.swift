import SwiftUI

// MARK: - 모델 (백엔드 사진 예시)
struct BackendPhoto: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let imageURL: URL
}

struct CollectedChangeView: View {
    // MARK: - 상태
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var showSheet: Bool = false

    @State private var photosByDay: [Date: [BackendPhoto]] = [:]
    @State private var selectedDayPhotos: [BackendPhoto] = []
    @State private var currentPhotoIndex: Int = 0

    // ✅ 사진은 없지만 ‘활동은 한’ 날
    @State private var activityDoneDays: Set<Date> = []

    // MARK: - 상수/유틸
    private let calendar = Calendar.current
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    private let columns = Array(repeating: GridItem(.fixed(40), spacing: 7), count: 7)

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
            guard let firstOfMonth = calendar.date(from: comps) else { return 0 }
            let weekday = calendar.component(.weekday, from: firstOfMonth) // 1:일~7:토
            return (weekday + 5) % 7 // 월(2)을 0으로 보정해서 월=0 시작
        }
    }

    // MARK: - 달력 보조
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
    private func dayKey(for day: Int) -> Date? {
        guard let d = dateFor(day: day) else { return nil }
        return calendar.startOfDay(for: d)
    }
    private func firstPhoto(of day: Int) -> BackendPhoto? {
        guard let key = dayKey(for: day) else { return nil }
        return photosByDay[key]?.first
    }

    // MARK: - 데모 데이터 로드(백엔드 연결 전)
    private func loadPhotosFromBackend() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        // 사진 있는 날(예시)
        let demoPhotos: [BackendPhoto] = [
            BackendPhoto(date: yesterday, imageURL: URL(string: "https://picsum.photos/seed/a/800/1200")!),
            BackendPhoto(date: yesterday.addingTimeInterval(3600), imageURL: URL(string: "https://picsum.photos/seed/b/800/1200")!),
            BackendPhoto(date: twoDaysAgo, imageURL: URL(string: "https://picsum.photos/seed/c/800/1200")!)
        ]

        var grouped: [Date: [BackendPhoto]] = [:]
        for p in demoPhotos {
            let key = calendar.startOfDay(for: p.date)
            grouped[key, default: []].append(p)
        }
        photosByDay = grouped

        // ✅ “활동만 하고 사진은 없는” 날(예시) → 파랑 원으로 표시됨
        activityDoneDays = [
            calendar.startOfDay(for: threeDaysAgo)
        ]
    }

    // MARK: - View
    var body: some View {
        let offset = CalendarHelper.firstWeekdayOffset(for: currentDate)
        let days = CalendarHelper.daysInMonth(for: currentDate)
        let totalCells = offset + days
        let numRows = Int(ceil(Double(totalCells) / 7.0))

        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0 ) {
                    // 헤더 (기존 UI 유지)
                    HStack {
                        Button { changeMonth(by: -1) } label: {
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundStyle(Color("Primary"))
                                .padding(.leading, 136)
                        }
                        Text(CalendarHelper.currentMonthText(from: currentDate))
                            .font(.body)
                            .foregroundColor(.black)
                        Button { changeMonth(by: 1) } label: {
                            Image(systemName: "arrowtriangle.right.fill")
                                .foregroundStyle(Color("Primary"))
                        }
                        Spacer()
                        Button { TodayDate() } label : {
                            Text("오늘")
                                .caption1()
                                .foregroundColor(Color("Primary"))
                                .frame(width: 40, height: 22)
                                .background(Color("Secondary"))
                                .cornerRadius(11)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)

                    // 요일
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 7)

                    // 날짜 그리드 (규칙 반영)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0..<(offset + days), id: \.self) { index in
                            if index < offset {
                                Color.clear
                                    .frame(width: 40, height: 40)
                            } else {
                                let day = index - offset + 1
                                let past = isPast(day: day)
                                let todayFlag = isToday(day: day)
                                let key = dayKey(for: day)

                                ZStack {
                                    if past {
                                        if let first = firstPhoto(of: day) {
                                            // 사진 인증 O → 썸네일
                                            AsyncImage(url: first.imageURL) { phase in
                                                switch phase {
                                                case .success(let img):
                                                    img.resizable()
                                                        .scaledToFill()
                                                        .frame(width: 40, height: 40)
                                                        .clipped()
                                                        .opacity(0.3)
                                                case .failure(_):
                                                    Color("Primary")
                                                case .empty:
                                                    Color.gray.opacity(0.15)
                                                @unknown default:
                                                    Color("Primary")
                                                }
                                            }
                                            .clipShape(Circle())
                                        } else if let k = key, activityDoneDays.contains(k) {
                                            // 사진 X + 활동 O → 파랑
                                            Color("Primary")
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        } else {
                                            // 사진 X + 활동 X → 회색(미수행)
                                            Color.gray.opacity(0.3)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                    } else {
                                        // 미래 날짜 → 회색
                                        Color.gray.opacity(0.3)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    }

                                    Text("\(day)")
                                        .foregroundColor(.white)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                        .opacity(todayFlag ? 1 : 0)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // 과거 날짜만 시트 열기(사진 유무 상관없이 열림)
                                    if past, let k = key {
                                        selectedDate = k
                                        selectedDayPhotos = photosByDay[k] ?? []
                                        currentPhotoIndex = 0
                                        showSheet = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 43)

                    Spacer(minLength: 0)
                }
                .padding(.top, 17)
                .frame(width: 353, height: numRows == 6 ? 390 : 350)
                .background(Color.white)
                .cornerRadius(10)
                .frame(maxHeight: .infinity, alignment: .top)
                .animation(nil, value: numRows)
            }
            .shadow(radius: 10)
        }
        .onAppear { loadPhotosFromBackend() }
        .sheet(isPresented: $showSheet) {
            PhotoSheetView(
                date: selectedDate ?? Date(),
                photos: selectedDayPhotos,
                currentIndex: $currentPhotoIndex
            ) {
                showSheet = false
            }
            .presentationDetents([.height(420), .medium])
        }
    }
}

// MARK: - 사진 시트
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
                                ZStack {
                                    Color.gray.opacity(0.08)
                                    ProgressView()
                                }
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
