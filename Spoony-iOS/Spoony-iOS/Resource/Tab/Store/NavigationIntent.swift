//
//  NavigationIntent.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/24/25.
//

import Foundation

enum NavigationIntent {
    case changeTab(TabType)
    case push(ViewType)
    case pop(Int)
    case popToRoot
    case showPopup(PopupType?)
    case changePath([ViewType], TabType)
    case changeCurrentLocation(String?)
}
