////
////  NavigationActor.swift
////  Spoony-iOS
////
////  Created by 이지훈 on 1/30/25.
////
//
//import SwiftUI
//
//actor NavigationCoordinator {
//    private var isNavigating = false
//
//    func coordinate(navigationManager: NavigationManager, result: SearchResult) async {
//        guard !isNavigating else { return }
//        isNavigating = true
//
//        do {
//            await MainActor.run {
//                navigationManager.pop(1)
//                navigationManager.push(.searchLocationView(
//                    locationId: result.locationId,
//                    locationTitle: result.title
//                ))
//            }
//        } catch {
//            print("Navigation error:", error)
//        }
//
//        isNavigating = false
//    }
//}
