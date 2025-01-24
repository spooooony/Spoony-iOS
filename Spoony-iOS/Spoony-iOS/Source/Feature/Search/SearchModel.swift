//
//  SearchModel.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/24/25.
//

import Foundation

struct SearchModel {
    var searchText: String = ""
    var recentSearches: [String] = UserManager.shared.recentSearches ?? []
    var isFirstAppear: Bool = true
    var isSearchFocused: Bool = false
}
