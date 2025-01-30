//
//  NavigationActor.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

actor NavigationCoordinator {
    private var isNavigating = false

    func coordinate(navigationManager: NavigationManager, result: SearchResult) async {
        guard !isNavigating else { return }
        isNavigating = true

        do {
            // 1. Prepare data before screen transition
            let targetLocationId = result.locationId
            let targetTitle = result.title

            // 2. Pop current screen
            await MainActor.run {
                navigationManager.pop(1)
            }

            // 3. Wait for UI update
            try await Task.sleep(nanoseconds: 300_000_000) // 300ms delay

            // 4. Ensure data is ready before pushing a new screen
            await MainActor.run {
                navigationManager.push(.searchLocationView(
                                   locationId: targetLocationId,
                                   locationTitle: targetTitle
                               ))            }
        } catch {
            print("Navigation error:", error)
        }

        // 5. Reset navigation state after all tasks are complete
        try? await Task.sleep(nanoseconds: 300_000_000)
        isNavigating = false
    }
}
