////
////  SearchLocationCardItem.swift
////  Spoony-iOS
////
////  Created by 이지훈 on 1/30/25.
////
//
//import SwiftUI
//
//import ComposableArchitecture
//
//struct SearchLocationListItem: View {
//    let place: PlaceItem
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            VStack(alignment: .leading, spacing: 8) {
//                HStack(spacing: 8) {
//                    Text(place.placeName)
//                        .customFont(.body1b)
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                    
//                    if let categoryName = place.categoryColorResponse.categoryName {
//                        HStack(spacing: 4) {
//                            if let iconUrl = place.categoryColorResponse.iconUrl, !iconUrl.isEmpty {
//                                AsyncImage(url: URL(string: iconUrl)) { phase in
//                                    switch phase {
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 16, height: 16)
//                                    default:
//                                        Color.clear
//                                            .frame(width: 16, height: 16)
//                                    }
//                                }
//                            }
//                            
//                            Text(categoryName)
//                                .customFont(.caption1m)
//                                .lineLimit(1)
//                        }
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(
//                            Color(hex: place.categoryColorResponse.iconBackgroundColor ?? "#EEEEEE")
//                        )
//                        .foregroundColor(
//                            Color(hex: place.categoryColorResponse.iconTextColor ?? "#000000")
//                        )
//                        .cornerRadius(12)
//                    }
//                }
//                
//                Text(place.placeAddress)
//                    .customFont(.caption1m)
//                    .foregroundColor(.gray600)
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                
//                Text(place.postTitle ?? "")
//                    .customFont(.caption1m)
//                    .foregroundColor(.spoonBlack)
//                    .lineLimit(1)
//                    .truncationMode(.tail)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(12)
//                    .background(.white)
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color(.gray0), lineWidth: 1)
//                    )
//                    .shadow(
//                        color: Color(.gray0),
//                        radius: 16,
//                        x: 0,
//                        y: 2
//                    )
//            }
//            
//            AsyncImage(url: URL(string: place.photoUrl)) { phase in
//                switch phase {
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFill()
//                case .failure, .empty, @unknown default:
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.gray.opacity(0.1))
//                }
//            }
//            .frame(width: 98.adjusted, height: 98.adjusted)
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .layoutPriority(0)
//        }
//        .padding(.horizontal, 16)
//        .frame(height: 120.adjusted)
//    }
//}
