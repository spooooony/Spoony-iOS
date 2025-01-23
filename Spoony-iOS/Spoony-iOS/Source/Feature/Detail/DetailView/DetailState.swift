//
//  DetailState.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

import Foundation

// MARK: - State

struct DetailState {
    var postId: Int = 0
    var userId: Int = 0
    var userName: String = "이명진"
    var photoUrlList: [String] = []
    var title: String = ""
    var date: String = ""
    var menuList: [String] = []
    var description: String = ""
    var placeName: String = ""
    var placeAddress: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var zzimCount: Int = 0
    var isZzim: Bool = false
    var isScoop: Bool = true
    var categoryName: String = ""
    var iconUrl: String = ""
    var iconTextColor: String = ""
    var iconBackgroundColor: String = ""
    var categoryColorResponse: DetailCategoryColorResponse = .init(categoryName: "", iconUrl: "", iconTextColor: "", iconBackgroundColor: "", categoryId: 0)
    var isMine: Bool = true
    
    // 추가 상태
    var isLoading: Bool = false
    var errorMessage: String?
    var toast: Toast?
}
