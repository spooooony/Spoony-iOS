//
//  CategoryChip.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

struct CategoryChip: Equatable {
    let image: Image
    let selectedImage: Image
    let title: String
    let priority: Int
    
    init(
        image: Image,
        selectedImage: Image,
        title: String,
        priority: Int = 0
    ) {
        self.image = image
        self.selectedImage = selectedImage
        self.title = title
        self.priority = priority
    }
    
    static func == (lhs: CategoryChip, rhs: CategoryChip) -> Bool {
        lhs.title == rhs.title
    }
}

extension CategoryChip {
    static func sample() -> [CategoryChip] {
        [
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "한식"),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "일식", priority: 1),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "중식", priority: 2),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "양식", priority: 3),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "퓨전/세계요리", priority: 4),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "카페", priority: 5),
            .init(image: Image(.icChineseGray600), selectedImage: Image(.icChineseWhite), title: "주류", priority: 6)
        ]
    }
}
