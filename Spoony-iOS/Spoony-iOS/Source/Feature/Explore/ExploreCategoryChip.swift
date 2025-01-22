//
//  ExploreCategoryChip.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import SwiftUI
//TODO: CategoryChipsView와 같이 쓸 수 있게 컴포넌트화 하기
struct ExploreCategoryChip: View {
    private let category: CategoryEntity
    private let selected: Bool
    
    init(category: CategoryEntity, selected: Bool) {
        self.category = category
        self.selected = selected
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let url = URL(string: selected ? category.selectedUrl : category.notSelectedUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16.adjusted, height: 16.adjusted)
                } placeholder: {
                    Color.clear
                        .frame(width: 16.adjusted, height: 16.adjusted)
                }
            } else {
                Color.clear
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            Text(category.name)
                .customFont(.body2sb)
                .foregroundStyle(selected ? .white : .gray600)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 14)
        .frame(height: 32.adjustedH)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: selected ? [
                            .spoonBlack,
                            .spoonBlack,
                            .spoonBlack,
                            .gray500
                    ] : [.gray0]
                ),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.gray100)
        }
    }
}

#Preview {
    ExploreCategoryChip(
        category: .init(
            id: 1,
            name: "전체",
            selectedUrl: "",
            notSelectedUrl: ""
        ),
        selected: true
    )
}
