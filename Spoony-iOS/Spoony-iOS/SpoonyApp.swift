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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @StateObject private var navigationManager = NavigationManager()
    
    init() {
        NMFAuthManager.shared().ncpKeyId = Config.naverMapsClientId
        KakaoSDK.initSDK(appKey: Config.kakaoAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                store: Store(initialState: .initialState) {
                    AppCoordinator()
                }
            )
            .onOpenURL(perform: { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            })
        }
    }
}
