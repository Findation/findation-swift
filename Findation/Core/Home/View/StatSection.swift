import SwiftUI

struct StatSection: View {
    @EnvironmentObject var session: SessionStore
    @State private var isLoading = false
    @State private var series: [Double] = []
    @State private var loadError: String? = nil
    @State private var loadedOnce = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 타이틀
            VStack(alignment: .leading, spacing: 8){
                Text("내 통계")
                    .bodytext()
                    .foregroundColor(Color(Color.primaryColor))
                Text("지난 일주일 간의 성취도를 확인하세요.")
                    .footNote()
                    .foregroundColor(Color(Color.darkGrayColor))
            }

            // 콘텐츠 영역
            Group {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 120)

                } else if series.isEmpty {
                    // 데이터 없음
                    ZStack {
                        Color.clear
                        Text("아직 데이터가 없어요")
                            .footNote()
                            .foregroundColor(Color(Color.darkGrayColor))
                    }
                    .frame(height: 120)

                } else {
                    GeometryReader { geo in
                        let data = series
                        let rawMax = data.max() ?? 0
                        let maxValue = rawMax > 0 ? rawMax : 1e-6
                        let w = geo.size.width
                        let h = geo.size.height

                        let verticalPadding: CGFloat = 8         
                        let usableH = max(h - verticalPadding * 2, 1)

                        let stepX = data.count > 1 ? w / CGFloat(data.count - 1) : 0

                        let points: [CGPoint] = data.enumerated().map { i, v in
                            let x = stepX * CGFloat(i)
                            let ratio = CGFloat(v) / CGFloat(maxValue)
                            let y = h - (ratio * usableH + verticalPadding)
                            return CGPoint(x: x, y: y)
                        }

                        ZStack {
                            if let first = points.first, let last = points.last {
                                Path { p in
                                    p.move(to: CGPoint(x: first.x, y: h - verticalPadding))
                                    for pt in points { p.addLine(to: pt) }
                                    p.addLine(to: CGPoint(x: last.x, y: h - verticalPadding))
                                    p.closeSubpath()
                                }
                                .fill(Color.secondaryColor)
                            }

                            Path { p in
                                guard let first = points.first else { return }
                                p.move(to: first)
                                for pt in points.dropFirst() { p.addLine(to: pt) }
                            }
                            .stroke(Color.primaryColor, lineWidth: 1.5)

                            ForEach(points.indices, id: \.self) { i in
                                Circle()
                                    .fill(Color.primaryColor)
                                    .frame(width: 4, height: 4)
                                    .position(points[i])
                            }
                        }
                    }
                    .frame(height: 120)

                    HStack {
                        Text("일주일 전")
                        Spacer()
                        Text("오늘")
                    }
                    .caption1()
                    .foregroundColor(Color("DarkGray"))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(hex: "A2C6FF"), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
        .task(id: session.isAuthenticated) {
            guard session.isAuthenticated else { return }
            await load()
        }
        .onAppear {
            if !loadedOnce {
                Task { await load() }
            }
        }
    }

    // MARK: - Load & Reduce
    private func load() async {
        if isLoading { return }
        isLoading = true
        loadError = nil
        defer {
            isLoading = false
            loadedOnce = true
        }

        do {
            let items = try await UsedTimeAPI.getUsedTimeByStartEndData()

            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            var buckets = Array(repeating: 0.0, count: 7)

            for d in items {
                let day = cal.startOfDay(for: d.date)
                guard let diff = cal.dateComponents([.day], from: day, to: today).day,
                      diff >= 0, diff < 7 else { continue }
                let idx = 6 - diff
                buckets[idx] += Double(d.usedTime) / 3600.0
            }

            let total = buckets.reduce(0, +)
            await MainActor.run {
                self.series = (total == 0) ? [] : buckets
            }
        } catch {
            await MainActor.run {
                self.series = []
                self.loadError = error.localizedDescription
            }
        }
    }
}
