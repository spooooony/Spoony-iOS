//
//  SpoonyApp.swift
//  SpoonMe
//
//  Created by 이지훈 on 12/26/24.
//

import SwiftUI

@main
struct SpoonyApp: App {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            SpoonyTabView()
                .environmentObject(navigationManager)
                .popup(popup: $navigationManager.popup)
        }
    }
}
