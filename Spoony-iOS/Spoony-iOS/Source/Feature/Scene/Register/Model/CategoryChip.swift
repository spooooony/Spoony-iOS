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
    
    static func mock() -> [CategoryChip] {
        return [
            .init(image: "", selectedImage: "", title: "한식", id: 2),
            .init(image: "", selectedImage: "", title: "일식", id: 3),
            .init(image: "", selectedImage: "", title: "중식", id: 4),
            .init(image: "", selectedImage: "", title: "양식", id: 5),
            .init(image: "", selectedImage: "", title: "카페", id: 6),
            .init(image: "", selectedImage: "", title: "주류", id: 7),
            .init(image: "", selectedImage: "", title: "퓨전/세계요리", id: 8)
        ]
    }
}
