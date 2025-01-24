//
//  NavigationState.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/24/25.
//

import Foundation

struct NavigationState {
    var selectedTab: TabType = .map
    var mapPath: [ViewType] = []
    var explorePath: [ViewType] = []
    var registerPath: [ViewType] = []
    var currentLocation: String?
    var popup: PopupType?
}
