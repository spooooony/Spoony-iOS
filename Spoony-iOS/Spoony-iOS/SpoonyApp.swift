//
//  SpoonyApp.swift
//  SpoonMe
//
//  Created by 이지훈 on 12/26/24.
//

import SwiftUI

import NMapsMap
import KakaoSDKAuth
import KakaoSDKCommon
import ComposableArchitecture

@main
struct SpoonyApp: App {
    @StateObject private var navigationManager: NavigationManager
    
    private let registerStore: StoreOf<RegisterFeature>
    
    init() {
        NMFAuthManager.shared().clientId = Config.naverMapsClientId
        KakaoSDK.initSDK(appKey: Config.kakaoAppKey)
        
        let navigationManager = NavigationManager()
        self._navigationManager = StateObject(wrappedValue: navigationManager)
        
        self.registerStore = StoreOf<RegisterFeature>(
            initialState: .initialState
        ) {
            RegisterFeature(navigationManager: navigationManager)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SpoonyTabView(store: registerStore)
                .environmentObject(navigationManager)
                .popup(popup: $navigationManager.popup)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
