//
//  SearchResult.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/16/25.
//

import Foundation

struct SearchResult: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let locationId: Int
    let address: String
}
