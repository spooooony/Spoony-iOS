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
    @StateObject private var navigationManager = NavigationManager()
    private let store: StoreOf<AppCoordinator> = .init(initialState: .initialState) {
        AppCoordinator()
    }
    
    init() {
        NMFAuthManager.shared().clientId = Config.naverMapsClientId
        KakaoSDK.initSDK(appKey: Config.kakaoAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
//            SpoonyTabView(store: registerStore)
            AppCoordinatorView(store: store)
                .environmentObject(navigationManager)
                .onOpenURL(perform: { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
