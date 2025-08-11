import SwiftUI

// 예시: 백엔드 레코드 (프로젝트에 맞게 수정 가능)
struct BackendPhoto: Identifiable, Hashable {
    let id = UUID()
    let date: Date              // 날짜+시간
    let imageURL: URL           // Asset/로컬 파일이면 타입 바꿔 사용
}

struct CollectedChangeView: View {
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date? = nil

    // 팝업 상태
    @State private var showPopup: Bool = false
    @State private var selectedDayPhotos: [BackendPhoto] = []
    @State private var currentPhotoIndex: Int = 0

    // 날짜별 사진
    @State private var photosByDay: [Date: [BackendPhoto]] = [:]

    private let calendar = Calendar.current
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    private let columns = Array(repeating: GridItem(.fixed(40), spacing: 7), count: 7)

    struct CalendarHelper {
        static func currentMonthText(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월"
            return formatter.string(from: date)
        }
        static func daysInMonth(for date: Date, calendar: Calendar = .current) -> Int {
            calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        }
        static func firstWeekdayOffset(for date: Date, calendar: Calendar = .current) -> Int {
            let comps = calendar.dateComponents([.year, .month], from: date)
            guard let firstOfMonth = calendar.date(from: comps) else { return 0 }
            let weekday = calendar.component(.weekday, from: firstOfMonth)
            return (weekday + 5) % 7
        }
    }

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

    // MARK: - 백엔드 로딩 (여기를 실제 데이터로 교체)
    private func loadPhotosFromBackend() {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // 데모 데이터
        let demo: [BackendPhoto] = [
            BackendPhoto(date: yesterday, imageURL: URL(string: "https://picsum.photos/seed/a/800/1200")!),
            BackendPhoto(date: yesterday.addingTimeInterval(3600), imageURL: URL(string: "https://picsum.photos/seed/b/800/1200")!)
        ]

        var grouped: [Date: [BackendPhoto]] = [:]
        for p in demo {
            let key = calendar.startOfDay(for: p.date)
            grouped[key, default: []].append(p)
        }
        photosByDay = grouped
    }

    private func dayKey(for day: Int) -> Date? {
        guard let d = dateFor(day: day) else { return nil }
        return calendar.startOfDay(for: d)
    }
    private func hasPhotos(day: Int) -> Bool {
        guard let key = dayKey(for: day) else { return false }
        return (photosByDay[key]?.isEmpty == false)
    }
    private func firstPhoto(of day: Int) -> BackendPhoto? {
        guard let key = dayKey(for: day) else { return nil }
        return photosByDay[key]?.first
    }

    var body: some View {
        let offset = CalendarHelper.firstWeekdayOffset(for: currentDate)
        let days = CalendarHelper.daysInMonth(for: currentDate)
        let totalCells = offset + days
        let numRows = Int(ceil(Double(totalCells) / 7.0))

        ZStack {
            // 메인 캘린더
            VStack(spacing: 0) {
                VStack(spacing: 0 ) {
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
                        Button { TodayDate() } label: {
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

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 7)

                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(0..<(offset + days), id: \.self) { index in
                            if index < offset {
                                Color.clear
                                    .frame(width: 40, height: 40)
                            } else {
                                let day = index - offset + 1
                                let isTodayFlag = isToday(day: day)
                                let past = isPast(day: day)

                                ZStack {
                                    if past {
                                        // 과거: 사진 배경(0.3) 또는 Primary
                                        if let first = firstPhoto(of: day) {
                                            AsyncImage(url: first.imageURL) { phase in
                                                switch phase {
                                                case .success(let img):
                                                    img
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 40, height: 40)
                                                        .clipped()
                                                        .opacity(0.3)
                                                case .failure(_):
                                                    Color("Primary").frame(width: 40, height: 40)
                                                case .empty:
                                                    Color.gray.opacity(0.15).frame(width: 40, height: 40)
                                                @unknown default:
                                                    Color("Primary").frame(width: 40, height: 40)
                                                }
                                            }
                                            .clipShape(Circle())
                                        } else {
                                            Color("Primary")
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        }
                                    } else {
                                        // 오늘·미래: 기존 스타일
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
                                        .opacity(isTodayFlag ? 1 : 0)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // 과거 날짜만 팝업
                                    if past, let key = dayKey(for: day) {
                                        selectedDate = key
                                        selectedDayPhotos = photosByDay[key] ?? []
                                        currentPhotoIndex = 0
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                            showPopup = true
                                        }
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

            // 팝업 오버레이
            if showPopup {
                // Dimmed
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { closePopup() }

                // 팝업 카드
                PopupPhotoViewer(
                    date: selectedDate ?? Date(),
                    photos: selectedDayPhotos,
                    currentIndex: $currentPhotoIndex,
                    onClose: { closePopup() }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .onAppear { loadPhotosFromBackend() }
    }

    private func closePopup() {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.95)) {
            showPopup = false
        }
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 (E)"
        return f.string(from: date)
    }
}

// MARK: - 팝업 뷰 (날짜 중앙, 화살표 중앙 높이, zIndex 수정)
fileprivate struct PopupPhotoViewer: View {
    let date: Date
    let photos: [BackendPhoto]
    @Binding var currentIndex: Int
    var onClose: () -> Void

    private let pillFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d"
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 1) 배경 이미지 (z: 0)
                if let current = photos[safe: currentIndex] {
                    AsyncImage(url: current.imageURL) { phase in
                        switch phase {
                        case .success(let img):
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure(_):
                            Color.gray.opacity(0.15)
                        case .empty:
                            ZStack {
                                Color.gray.opacity(0.08)
                                ProgressView()
                            }
                        @unknown default:
                            Color.gray.opacity(0.15)
                        }
                    }
                } else {
                    Color.gray.opacity(0.1)
                }

                // 2) 어둡게 (z: 0) — 항상 아래
                Rectangle()
                    .fill(.black.opacity(0.35))
                    .ignoresSafeArea()
                    .zIndex(0)

                // 3) 닫기 버튼 (오른쪽 상단, z: 2)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 12)
                    Spacer()
                }
                .zIndex(2)

                // 4) 날짜 Pill (상단 중앙, z: 2)
                VStack {
                    Text(pillFormatter.string(from: date))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("Primary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 2)
                        .padding(.top, 12)
                    Spacer()
                }
                .zIndex(2)

                // 5) 좌우 화살표 (세로 중앙, z: 2)
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            currentIndex = max(0, currentIndex - 1)
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0.5 : 1)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            currentIndex = min(photos.count - 1, currentIndex + 1)
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .disabled(currentIndex >= max(photos.count - 1, 0))
                    .opacity(currentIndex >= max(photos.count - 1, 0) ? 0.5 : 1)
                }
                .padding(.horizontal, 12)
                .zIndex(2)
            }
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            // 페이지 인디케이터
            HStack(spacing: 6) {
                ForEach(0..<(max(photos.count, 1)), id: \.self) { i in
                    Circle()
                        .frame(width: i == currentIndex ? 8 : 6, height: i == currentIndex ? 8 : 6)
                        .foregroundStyle(i == currentIndex ? .white : .white.opacity(0.5))
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: 520)
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)
        .gesture(
            DragGesture(minimumDistance: 15)
                .onEnded { value in
                    if value.translation.width < -40, currentIndex < photos.count - 1 {
                        withAnimation(.easeInOut(duration: 0.18)) { currentIndex += 1 }
                    } else if value.translation.width > 40, currentIndex > 0 {
                        withAnimation(.easeInOut(duration: 0.18)) { currentIndex -= 1 }
                    }
                }
        )
    }
}

// 안전 인덱싱
fileprivate extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    CollectedChangeView()
}
