//
//  CategoryChip.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

struct CategoryChip: Equatable {
    let image: String
    let selectedImage: String
    let title: String
    let id: Int
    
    init(
        image: String,
        selectedImage: String,
        title: String,
        id: Int
    ) {
        self.image = image
        self.selectedImage = selectedImage
        self.title = title
        self.id = id
    }
    
    static func == (lhs: CategoryChip, rhs: CategoryChip) -> Bool {
        lhs.id == rhs.id
    }
}

extension CategoryChip {
    static let placeholder: CategoryChip = .init(
        image: "",
        selectedImage: "",
        title: "",
        id: 0
    )
}
