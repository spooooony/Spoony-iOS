//
//  SearchLocationCardItem.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/30/25.
//

import SwiftUI

struct SearchLocationCardItem: View {
    let pickCard: SearchLocationResult
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(pickCard.title)
                        .customFont(.body1b)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    if let category = pickCard.categoryColorResponse {
                        HStack(spacing: 4) {
                            AsyncImage(url: URL(string: category.iconUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16.adjusted, height: 16.adjustedH)
                                default:
                                    Color.clear
                                        .frame(width: 16.adjusted, height: 16.adjustedH)
                                }
                            }
                            
                            Text(category.categoryName)
                                .customFont(.caption1m)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: category.iconBackgroundColor))
                        .foregroundColor(Color(hex: category.iconTextColor))
                        .cornerRadius(12)
                    }
                }
                
                Text(pickCard.address)
                    .customFont(.caption1m)
                    .foregroundColor(.gray600)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if let postTitle = pickCard.postTitle {
                    Text(postTitle)
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
            }
            AsyncImage(url: URL(string: pickCard.photoUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    defaultPlaceholder
                case .empty:
                    defaultPlaceholder
                default:
                    defaultPlaceholder
                }
            }
            .frame(width: 98.adjusted, height: 98.adjusted)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .layoutPriority(0)
        }
        .padding(.horizontal, 16)
        .frame(height: 120.adjusted)
    }
    
    private var defaultPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
    }
}
