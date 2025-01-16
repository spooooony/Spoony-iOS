//
//  SearchResult.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/17/25.
//

import Foundation

struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let address: String
}
