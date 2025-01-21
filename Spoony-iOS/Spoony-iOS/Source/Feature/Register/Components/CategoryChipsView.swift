//
//  CategoryChipsView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

import Kingfisher

struct CategoryChipsView: View {
    private var category: CategoryChip
    private var isSelected: Bool
    
    init(category: CategoryChip, isSelected: Bool = false) {
        self.category = category
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Group {
                if isSelected {
                    if let url = URL(string: category.selectedImage) {
                        KFImage(url)
                            .resizable()
                    }
                } else {
                    if let url = URL(string: category.image) {
                        KFImage(url)
                            .resizable()
                    }
                }
            }
            .frame(width: 16.adjusted, height: 16.adjustedH)
            
            Text(category.title)
                .font(.body2sb)
                .foregroundStyle(isSelected ? .white : .gray600)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .main400 : .gray0)
                .strokeBorder(.gray100)
        }
    }
}
