//
//  PlaceCardsContainer.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

//struct PlaceCardsContainer: View {
//    let places: [CardPlace]
//    @Binding var currentPage: Int
//    
//    var body: some View {
//        TabView(selection: $currentPage) {
//            ForEach(Array(places.enumerated()), id: \.element.id) { index, place in
//                PlaceCard(
//                    placeName: place.name,
//                    visitorCount: place.visitorCount,
//                    address: place.address,
//                    images: place.images,
//                    title: place.title,
//                    subTitle: place.subTitle,
//                    description: place.description,
//                    categoryColor: place.categoryColor,
//                    categoryTextColor: place.categoryTextColor
//                )
//                .tag(index)
//            }
//        }
//        .padding(.horizontal, 16)
//        .frame(height: 280.adjusted)
//        .tabViewStyle(.page(indexDisplayMode: .never))
//        .background(Color.clear) // 배경을 투명하게 설정
//    }
//}
//
//#Preview {
// Home()
//}
