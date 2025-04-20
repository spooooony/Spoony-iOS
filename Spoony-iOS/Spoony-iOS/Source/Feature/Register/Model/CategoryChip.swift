//
//  CategoryChip.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

struct CategoryChip: Equatable, Identifiable {
    let image: String
    let selectedImage: String
    let title: String
    let id: Int
    
    static func == (lhs: CategoryChip, rhs: CategoryChip) -> Bool {
        lhs.id == rhs.id
    }
}

extension CategoryChip {
    static let placeholder: CategoryChip = .init(
        image: "",
        selectedImage: "",
        title: "중식",
        id: 0
    )
}
