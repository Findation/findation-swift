//
//  RoutineViewModel.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/8/25.
//

import Foundation

final class RoutinesViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var isLoading = false
    @Published var error: String?
    
    @Published private(set) var completedToday: Set<String> = []

    private let storeKeyPrefix = "completedRoutineIDs_"

    private var todayKey: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return storeKeyPrefix + f.string(from: Date())
    }

    init() {
        loadCompletedToday()
    }
    
    private let elapsedKeyPrefix = "elapsedById_"

    private var todayElapsedKey: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return elapsedKeyPrefix + f.string(from: Date())
    }

    private func saveElapsedTimes() {
        let dict = Dictionary(uniqueKeysWithValues: routines.map { ($0.id, $0.elapsedTime) })
        UserDefaults.standard.set(dict, forKey: todayElapsedKey)
    }

    private func loadElapsedTimes() -> [String: Double] {
        (UserDefaults.standard.dictionary(forKey: todayElapsedKey) as? [String: Double]) ?? [:]
    }
    
    @MainActor
    func incrementElapsed(for id: String, by seconds: TimeInterval) {
        guard let i = routines.firstIndex(where: { $0.id == id }) else { return }
        routines[i].elapsedTime += seconds
        saveElapsedTimes() // ← 변경사항 영구 저장
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // 0) 오늘 저장된 elapsed 로드
            let persistedElapsed = loadElapsedTimes()

            // 1) 서버에서 최신 루틴
            let fetched = try await RoutineAPI.getRoutines()

            // 2) 기존 메모리 elapsed 보존(앱 실행 중 변경분 유지용)
            let inMemoryElapsed = Dictionary(uniqueKeysWithValues: routines.map { ($0.id, $0.elapsedTime) })

            // 3) 하나의 루프에서 완료상태 + elapsed 머지
            var merged: [Routine] = []
            merged.reserveCapacity(fetched.count)
            for var r in fetched {
                // (완료 상태) UserDefaults의 completedToday 반영
                r.isCompleted = completedToday.contains(r.id)

                // (elapsed) 우선순위: 실행 중 변경값 > 저장값 > 서버값(0)
                if let mem = inMemoryElapsed[r.id] {
                    r.elapsedTime = mem
                } else if let saved = persistedElapsed[r.id] {
                    r.elapsedTime = saved
                }
                merged.append(r)
            }
            self.routines = merged
        } catch {
            print("load() failed:", error)
        }
    }

    @MainActor
    func markCompleted(_ id: String, moveToBottom: Bool = true) {
        completedToday.insert(id)
        saveCompletedToday()

        if let idx = routines.firstIndex(where: { $0.id == id }) {
            routines[idx].isCompleted = true
            if moveToBottom {
                let item = routines.remove(at: idx)
                routines.append(item)
            }
        }
    }

    // MARK: - Private helpers
    private func mergeWithCompletedToday(_ list: [Routine]) -> [Routine] {
        list.map { r in
            var rr = r
            rr.isCompleted = completedToday.contains(r.id)
            return rr
        }
    }

    private func saveCompletedToday() {
        UserDefaults.standard.set(Array(completedToday), forKey: todayKey)
    }

    private func loadCompletedToday() {
        if let arr = UserDefaults.standard.array(forKey: todayKey) as? [String] {
            completedToday = Set(arr)
        } else {
            completedToday = []
        }
    }
}
