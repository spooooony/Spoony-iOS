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
    var title: String = "내용 없음"
    var date: String = "2025-08-21"
    var menuList: [String] = ["하이"]
    var description: String = "서버통신이 실패 했어요"
    var placeName: String = ""
    var placeAddress: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var zzimCount: Int = 0
    var isZzim: Bool = false
    var isScoop: Bool = false
    var categoryName: String = ""
    var iconUrl: String = ""
    var iconTextColor: String = ""
    var iconBackgroundColor: String = ""
    var categoryColorResponse: DetailCategoryColorResponse = .init(categoryName: "", iconUrl: "", iconTextColor: "", iconBackgroundColor: "", categoryId: 0)
    var isMine: Bool = false
    var spoonCount: Int = 0
    
    // 추가 상태
    var isLoading: Bool = false
    var errorMessage: String?
    var toast: Toast?
    
    var successService: Bool = true
    
    var userImageUrl: String = ""
    var regionName: String = ""
}
