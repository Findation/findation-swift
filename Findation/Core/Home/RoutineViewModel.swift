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

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // 1) 기존 로컬 상태 백업
            let elapsedById = Dictionary(uniqueKeysWithValues: routines.map { ($0.id, $0.elapsedTime) })
            let completedById = Dictionary(uniqueKeysWithValues: routines.map { ($0.id, $0.isCompleted) })

            // 2) 서버에서 최신 루틴 받기
            let fetched = try await RoutineAPI.getRoutines()

            // 3) 로컬 상태를 머지해서 보존
            var merged: [Routine] = []
            merged.reserveCapacity(fetched.count)
            for var r in fetched {
                if let oldElapsed = elapsedById[r.id] {
                    r.elapsedTime = oldElapsed
                }
                if let oldCompleted = completedById[r.id] {
                    r.isCompleted = oldCompleted
                }
                merged.append(r)
            }
            self.routines = merged
        } catch {
            // 에러 핸들: 필요시 로그/알럿
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
