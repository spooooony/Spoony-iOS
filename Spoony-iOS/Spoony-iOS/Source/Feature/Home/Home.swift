//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
// 사용 예시
struct Home: View {
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        Text("Home")
    }
}
