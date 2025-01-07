//
//  SpoonMeApp.swift
//  SpoonMe
//
//  Created by 이지훈 on 12/26/24.
//

import SwiftUI

@main
struct SpoonMeApp: App {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            SpoonyTabView()
                .environmentObject(navigationManager)
        }
    }
}
