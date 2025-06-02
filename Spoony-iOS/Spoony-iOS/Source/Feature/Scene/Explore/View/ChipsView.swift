//
//  ChipsView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/30/25.
//

import SwiftUI

import Kingfisher

// TODO: CategoryChipsView 흡수하기 -> Components로 폴더로 이동
struct ChipsView: View {
    private let title: String
    private let selectedImageString: String?
    private let imageString: String?
    private let isSelected: Bool
    
    init(
        title: String,
        selectedImageString: String? = nil,
        imageString: String? = nil,
        isSelected: Bool
    ) {
        self.title = title
        self.selectedImageString = selectedImageString
        self.imageString = imageString
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Group {
                if isSelected {
                    if let imageURL = selectedImageString,
                       let url = URL(string: imageURL) {
                        KFImage(url)
                            .resizable()
                    }
                } else {
                    if let imageURL = imageString,
                       let url = URL(string: imageURL) {
                        KFImage(url)
                            .resizable()
                    }
                }
            }
            .frame(width: 16.adjusted, height: 16.adjustedH)
            
            Text(title)
                .customFont(.body2sb)
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
