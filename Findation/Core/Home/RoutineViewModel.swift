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

    func load() async {
        await MainActor.run { isLoading = true; error = nil }

        do {
            let data = try await RoutineAPI.getRoutines()
            let merged = mergeWithCompletedToday(data)

            await MainActor.run {
                self.routines = merged
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
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
