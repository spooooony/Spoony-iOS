//
//  AppDelegate.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import UIKit

import Mixpanel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Mixpanel.initialize(token: Config.mixpanelToken, automaticPushTracking: false)
        
        let isFirstOpen = UserManager.shared.isFirstOpenApp()
        
        Mixpanel.mainInstance().track(
            event: ConversionAnalysisEvents.Name.appOpen,
            properties: ConversionAnalysisEvents.AppOpenProperty(isFirstTime: isFirstOpen).dictionary
        )
        
        return true
    }
}
