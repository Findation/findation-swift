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

    func load() async {
        await MainActor.run { isLoading = true; error = nil }
        do {
            let data = try await RoutineAPI.getRoutines()
            await MainActor.run {
                self.routines = data
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
