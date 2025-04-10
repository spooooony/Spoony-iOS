//
//  BottomSheetItem.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

struct BottomSheetListItem: View {
    let pickCard: PickListCardResponse
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(pickCard.placeName)
                        .customFont(.body1b)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if let categoryName = pickCard.categoryColorResponse.categoryName {
                        HStack(spacing: 4) {
                            if let iconUrl = pickCard.categoryColorResponse.iconUrl, !iconUrl.isEmpty {
                                CachedImage(url: iconUrl) {
                                    Color.clear
                                }
                                .frame(width: 16.adjusted, height: 16.adjustedH)
                            }
                            
                            Text(categoryName)
                                .customFont(.caption1m)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color(hex: pickCard.categoryColorResponse.iconBackgroundColor ?? "#EEEEEE")
                        )
                        .foregroundColor(
                            Color(hex: pickCard.categoryColorResponse.iconTextColor ?? "#000000")
                        )
                        .cornerRadius(12)
                    }
                }
                
                Text(pickCard.placeAddress)
                    .customFont(.caption1m)
                    .foregroundColor(.gray600)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(pickCard.postTitle ?? "")
                    .customFont(.caption1m)
                    .foregroundColor(.spoonBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.gray0), lineWidth: 1)
                    )
                    .shadow(
                        color: Color(.gray0),
                        radius: 16,
                        x: 0,
                        y: 2
                    )
            }
            
            CachedImage(url: pickCard.photoUrl) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            }
            .frame(width: 98.adjusted, height: 98.adjusted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .layoutPriority(0)
        }
        .padding(.horizontal, 16)
        .frame(height: 120.adjusted)
    }
}
