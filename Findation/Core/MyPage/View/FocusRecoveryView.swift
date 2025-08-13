import SwiftUI

struct FocusRecoveryView: View {
    // MARK: - 상태
    @State private var cumulativePoints: [CGFloat] = []  // 누적 0~100
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 보기 모드
    enum ChartMode: String, CaseIterable, Identifiable {
        case cumulative = "6개월 변화량"
        case tenDay     = "10일 변화량"
        var id: String { rawValue }
    }
    @State private var mode: ChartMode = .cumulative

    // 🔹 더미 데이터 사용 여부 (실기기에서도 확인용)
    @State private var useDummyData: Bool = true

    // 상수
    private let totalDays: Int = 183
    private let baseDailyGain: Double = 100.0 / 183.0
    private let dailyTimeTargetMinutes: Double = 120.0

    // 프리뷰용 주입
    init(previewData: [CGFloat]? = nil) {
        if let series = previewData {
            _cumulativePoints = State(initialValue: series)
            _isLoading        = State(initialValue: false)
            _errorMessage     = State(initialValue: nil)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더(고정 높이)
            VStack(spacing: 8) {
                Text("집중력 회복")
                    .bodytext()
                    .foregroundColor(Color("Primary"))

                Picker("", selection: $mode) {
                    ForEach(ChartMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)

                // 🔹 더미 데이터 토글 (기기에서도 확인 가능)
                Toggle("더미 데이터 사용", isOn: $useDummyData)
                    .font(.footnote)
                    .tint(Color("Primary"))
                    .padding(.horizontal, 12)
            }
            .padding(.top, 15)
            .frame(maxWidth: .infinity)
            .frame(height: 120) // ← 제목/세그/토글 영역 높이 고정

            if let msg = errorMessage {
                Text(msg).foregroundColor(.red).padding(.vertical, 4)
            }

            // 그래프
            Group {
                if isLoading {
                    ProgressView().frame(height: 220)
                } else {
                    GeometryReader { geo in
                        let width  = geo.size.width
                        let height = geo.size.height

                        let cum = cumulativePoints
                        let ten = tenDayBlockDeltas(from: cum)

                        // 모드별 설정을 외부 헬퍼에서 계산
                        let cfg = chartConfig(mode: mode, cumulative: cum, tenDay: ten)

                        LineAreaChart(
                            values: cfg.series,
                            yMin: cfg.yMin,
                            yMax: cfg.yMax,
                            yTicks: cfg.yTicks,
                            width: width,
                            height: height
                        )
                    }
                    .frame(height: 220)
                    .padding(.horizontal, 15)
                }
            }
            .padding(.bottom, 15)
        }
        .frame(minWidth: 353, maxWidth: 353, minHeight: 360, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color(hex: "A2C6FF"), radius: 4, x: 0, y: 2)
        .cornerRadius(10)
        .task {
            if cumulativePoints.isEmpty { await buildRecoverySeries() }
        }
        .onChange(of: useDummyData) { _ in
            Task { await buildRecoverySeries() } // 토글 변경 시 재계산
        }
    }

    // 모드별 차트 스케일/데이터 설정
    private func chartConfig(
        mode: ChartMode,
        cumulative: [CGFloat],
        tenDay: [CGFloat]
    ) -> (series: [CGFloat], yMin: CGFloat, yMax: CGFloat, yTicks: [CGFloat]) {
        switch mode {
        case .cumulative:
            let series = cumulative
            let yMin: CGFloat = 0
            let yMax: CGFloat = 100
            let yTicks = stride(from: 0, through: 100, by: 20).map { CGFloat($0) }
            return (series, yMin, yMax, yTicks)

        case .tenDay:
            let series = tenDay
            let maxDelta = series.max() ?? 0
            let minDelta = series.min() ?? 0
            // 10일 이론치(≈5.5)에 여유를 둔다
            let yMin = min(0, minDelta * 1.1)
            let yMax = max(5.5, maxDelta * 1.1)
            let upper = max(ceil(yMax), 6.0) // 6 고정 상한으로 레이블 겹침 여유
            let start = floor(yMin)
            let yTicks = stride(from: start, through: upper, by: 1).map { CGFloat($0) }
            return (series, yMin, yMax, yTicks)
        }
    }
}

// MARK: - 공용 라인/면 그래프
private struct LineAreaChart: View {
    let values: [CGFloat]
    let yMin: CGFloat
    let yMax: CGFloat
    let yTicks: [CGFloat]
    let width: CGFloat
    let height: CGFloat

    // y축(라벨) 영역 너비
    private let yAxisWidth: CGFloat = 30
    // 라벨 최소 간격(pt) — 이보다 좁으면 일부 라벨을 숨김
    private let minLabelGap: CGFloat = 14

    var body: some View {
        ZStack(alignment: .topLeading) {
            let filteredTicks = filterTicks(yTicks, minGap: minLabelGap)

            // 그리드 + 라벨
            ForEach(filteredTicks, id: \.self) { tick in
                let y = toY(tick)
                Path { p in
                    p.move(to: CGPoint(x: yAxisWidth, y: y))
                    p.addLine(to: CGPoint(x: width,      y: y))
                }
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)

                Text(label(for: tick))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .frame(width: yAxisWidth - 4, alignment: .trailing)
                    .position(x: (yAxisWidth - 4) / 2, y: clamp(y, 8, height - 8))
            }

            // 채워진 영역
            Path { path in
                guard !values.isEmpty else { return }
                let stepX = step(plotWidth: width - yAxisWidth)
                path.move(to: CGPoint(x: yAxisWidth + 0, y: toY(values[0])))
                for i in 1..<values.count {
                    path.addLine(to: CGPoint(x: yAxisWidth + CGFloat(i) * stepX, y: toY(values[i])))
                }
                path.addLine(to: CGPoint(x: width, y: height))
                path.addLine(to: CGPoint(x: yAxisWidth, y: height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color("Primary").opacity(0.30), .clear]),
                    startPoint: .top, endPoint: .bottom
                )
            )

            // 라인
            Path { path in
                guard !values.isEmpty else { return }
                let stepX = step(plotWidth: width - yAxisWidth)
                path.move(to: CGPoint(x: yAxisWidth + 0, y: toY(values[0])))
                for i in 1..<values.count {
                    path.addLine(to: CGPoint(x: yAxisWidth + CGFloat(i) * stepX, y: toY(values[i])))
                }
            }
            .stroke(Color("Primary"), lineWidth: 1.2)
        }
        .clipped()
    }

    // Helpers
    private func step(plotWidth: CGFloat) -> CGFloat {
        let count = max(1, values.count)
        return count > 1 ? (plotWidth / CGFloat(count - 1)) : 0
    }

    private func toY(_ v: CGFloat) -> CGFloat {
        guard yMax > yMin else { return height }
        let t = (v - yMin) / (yMax - yMin)
        return height - (t * height)
    }

    private func label(for tick: CGFloat) -> String {
        abs(tick.rounded() - tick) < 0.0001
        ? String(format: "%.0f", tick)
        : String(format: "%.1f", tick)
    }

    private func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(v, lo), hi)
    }

    /// 눈금 라벨 간 최소 간격 보장
    private func filterTicks(_ ticks: [CGFloat], minGap: CGFloat) -> [CGFloat] {
        guard ticks.count > 1 else { return ticks }
        var result: [CGFloat] = []
        var lastY: CGFloat? = nil
        for t in ticks.sorted(by: >) { // 위에서 아래로
            let y = toY(t)
            if let ly = lastY, abs(ly - y) < minGap { continue }
            result.append(t)
            lastY = y
        }
        return result
    }
}

// MARK: - 데이터 계산
private extension FocusRecoveryView {
    func buildRecoverySeries() async {
        isLoading = true
        errorMessage = nil

        // 🔹 더미 모드: 기기/시뮬레이터/프리뷰 어디서든 즉시 확인
        if useDummyData {
            let dummy = FocusRecoveryView.makeDummyCumulative(days: totalDays)
            await MainActor.run {
                self.cumulativePoints = dummy
                self.isLoading = false
            }
            return
        }

        // 🔻 실제 API 모드 (원 코드 로직 유지)
        do {
            let allRoutines = try await RoutineAPI.getRoutines()
            let today = Date()
            let startDate = Calendar.current.date(byAdding: .day, value: -(totalDays - 1), to: today)!.startOfDay

            var points: [CGFloat] = []
            var cumulative: Double = 0

            for dayOffset in 0..<totalDays {
                let dayStart = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!.startOfDay
                let dayEnd   = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!.startOfDay

                // 시간 기여도 (UsedTime 배열 합산 → 초 → 분)
                let usedSeconds: Int = (try? await UsedTimeAPI
                    .getUsedTimeByStartEndData(startDate: dayStart, endDate: dayEnd)
                )?.reduce(0, { $0 + $1.usedTime }) ?? 0

                let usedMinutes = Double(usedSeconds) / 60.0
                let timeContribution = max(0, min(usedMinutes / dailyTimeTargetMinutes, 1))

                // 루틴 기여도
                let routinesOfTheDay = allRoutines.filter { $0.matches(date: dayStart) || $0.isNotRepeated() }
                let totalCount = max(1, routinesOfTheDay.count)
                let doneCount = try await completedCount(on: dayStart, in: routinesOfTheDay)
                let routineContribution = Double(doneCount) / Double(totalCount)

                // 일일 증가량
                let dailyGain = (doneCount == 0)
                ? -baseDailyGain
                : baseDailyGain * timeContribution * routineContribution

                cumulative = max(0, min(100, cumulative + dailyGain))
                points.append(CGFloat(cumulative))
            }

            await MainActor.run {
                self.cumulativePoints = points
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "데이터 로딩 실패: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// 오늘은 메모리(isCompleted)로, 과거는 0으로 가정 (실서비스는 완료 이력 조회 필요)
    private func completedCount(on date: Date, in routines: [Routine]) async throws -> Int {
        Calendar.current.isDateInToday(date) ? routines.filter { $0.isCompleted }.count : 0
    }
}

// MARK: - 10일 변화량 계산 (누적 → 일간 → 10일 블록 합)
// 마지막 부분이 10일 미만이면 (합계 / 일수) * 10 으로 정규화해 급락 방지
private func tenDayBlockDeltas(from cumulative: [CGFloat]) -> [CGFloat] {
    guard !cumulative.isEmpty else { return [] }

    // 일간 변화량
    var daily: [CGFloat] = []
    daily.reserveCapacity(cumulative.count)
    daily.append(cumulative[0])
    for i in 1..<cumulative.count {
        daily.append(cumulative[i] - cumulative[i-1])
    }

    let window = 10
    var out: [CGFloat] = []
    var i = 0
    while i < daily.count {
        let end = min(i + window, daily.count)
        let slice = daily[i..<end]
        let sum = slice.reduce(0, +)
        let n = CGFloat(end - i)

        // 마지막 부분이 10일 미만이면 10일 기준으로 정규화
        let normalized = (n < CGFloat(window)) ? (sum * (CGFloat(window) / n)) : sum
        out.append(normalized)

        i += window
    }
    return out
}

// MARK: - 날짜 유틸
private extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}

#if DEBUG
// MARK: - 더미 데이터 생성기
extension FocusRecoveryView {
    static func makeDummyCumulative(days: Int = 183) -> [CGFloat] {
        var v: CGFloat = 0
        return (0..<days).map { _ in
            // 평균 0.35~0.6 정도 오르고 약간의 노이즈
            let base = CGFloat.random(in: 0.35...0.60)
            let noise = CGFloat.random(in: -0.12...0.12)
            v = max(0, min(100, v + base + noise))
            return v
        }
    }
}

// MARK: - 프리뷰
struct FocusRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        FocusRecoveryView(previewData: FocusRecoveryView.makeDummyCumulative())
            .environment(\.colorScheme, .light)
            .previewLayout(.sizeThatFits)
            .frame(width: 353, height: 380)
    }
}
#endif
