import SwiftUI

// MARK: - Demo 모델 (백엔드 연결 전)
struct BackendPhoto: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let imageURL: URL
}

struct CollectedChangeView: View {
    // MARK: State
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var showSheet: Bool = false

    @State private var photosByDay: [Date: [BackendPhoto]] = [:]
    @State private var selectedDayPhotos: [BackendPhoto] = []
    @State private var currentPhotoIndex: Int = 0

    // 사진은 없지만 ‘활동은 한’ 날
    @State private var activityDoneDays: Set<Date> = []

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
    private func dayKey(for day: Int) -> Date? {
        guard let d = dateFor(day: day) else { return nil }
        return calendar.startOfDay(for: d)
    }
    private func firstPhoto(of day: Int) -> BackendPhoto? {
        guard let key = dayKey(for: day) else { return nil }
        return photosByDay[key]?.first
    }

    // MARK: Demo Data
    private func loadPhotosFromBackend() {
        let today = Date()
        let d1 = calendar.date(byAdding: .day, value: -1, to: today)! // 어제(사진 2장)
        let d2 = calendar.date(byAdding: .day, value: -2, to: today)! // 그제(사진 1장)
        let d3 = calendar.date(byAdding: .day, value: -3, to: today)! // 활동만 O

        let demo: [BackendPhoto] = [
            BackendPhoto(date: d1, imageURL: URL(string: "https://picsum.photos/seed/a/800/1200")!),
            BackendPhoto(date: d1.addingTimeInterval(3600), imageURL: URL(string: "https://picsum.photos/seed/b/800/1200")!),
            BackendPhoto(date: d2, imageURL: URL(string: "https://picsum.photos/seed/c/800/1200")!)
        ]

        var grouped: [Date: [BackendPhoto]] = [:]
        for p in demo {
            let key = calendar.startOfDay(for: p.date)
            grouped[key, default: []].append(p)
        }
        photosByDay = grouped
        activityDoneDays = [calendar.startOfDay(for: d3)]
    }

    // MARK: View
    var body: some View {
        let offset = CalendarHelper.firstWeekdayOffset(for: currentDate)
        let days = CalendarHelper.daysInMonth(for: currentDate)
        let totalCells = offset + days
        let numRows = Int(ceil(Double(totalCells) / 7.0))

        VStack(spacing: 0) {
            // 헤더
            HStack {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundStyle(Color("Primary"))
                }
                Text(CalendarHelper.currentMonthText(from: currentDate))
                    .font(.body)
                    .foregroundColor(.black)
                    .frame(minWidth: 60)

                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "arrowtriangle.right.fill")
                        .foregroundStyle(Color("Primary"))
                }

                Spacer()

                Button { TodayDate() } label: {
                    Text("오늘")
                        .caption1()
                        .foregroundColor(Color("Primary"))
                        .frame(width: 40, height: 22)
                        .background(Color("Secondary"))
                        .cornerRadius(11)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 17)
            .padding(.bottom, 12)

            // 요일 & 날짜 (동적 dotSize로 겹침/잘림 방지)
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
                            .font(.caption)
                            .foregroundColor(.black)
                            .frame(width: dot, height: 22) // 고정 높이로 겹침 방지
                    }
                }
                .padding(.horizontal, horizontalInset)

                // 요일과 날짜 사이 여백
                VStack { Spacer().frame(height: 6) }.frame(maxWidth: .infinity, maxHeight: .infinity)

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
                                                    .frame(width: dot, height: dot)
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
                                        // 활동 O & 사진 X → 파란색
                                        Color("Primary")
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
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: dot, height: dot)
                                    .opacity(todayFlag ? 1 : 0)
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
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
                .padding(.horizontal, horizontalInset)
                .padding(.top, 28)   // 요일줄과 확실히 분리
                .padding(.bottom, 20)
            }
            // GeometryReader가 카드 높이 내에서만 계산하도록 고정 높이
            .frame(height: (numRows == 6 ? 234 : 214))

            Spacer(minLength: 0)
        }
        // 카드 스타일 (랭킹 카드와 동일)
        .frame(width: 353, height: numRows == 6 ? 390 : 350, alignment: .top)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 8)
        .onAppear { loadPhotosFromBackend() }
        .sheet(isPresented: $showSheet) {
            PhotoSheetView(
                date: selectedDate ?? Date(),
                photos: selectedDayPhotos,
                currentIndex: $currentPhotoIndex
            ) { showSheet = false }
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
