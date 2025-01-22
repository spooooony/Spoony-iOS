//
//  PlaceCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceCard: View {
    let places: [CardPlace]
    @Binding var currentPage: Int
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(places.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        PlaceImagesLayout(images: places[index].images)
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 6) {
                                Text(places[index].name)
                                    .customFont(.body1b)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "mug.fill")
                                    Text(places[index].description)
                                        .customFont(.system(size: 14.5))
                                }
                                .foregroundColor(Color(hex: places[index].categoryTextColor))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: places[index].categoryColor).opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(.icAddmapGray400)
                                    Text(places[index].visitorCount)
                                        .customFont(.caption2b)
                                }
                            }
                        }
                        .padding(15)
                    }
                    .background(Color.white)
                    
                    // 하단 정보 부분
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(places[index].title)
                                .customFont(.body2b)
                                .lineLimit(1)
                            Text(places[index].address)
                                .customFont(.caption1m)
                                .foregroundColor(.gray600)
                        }
                        Text(places[index].subTitle)
                            .customFont(.caption1m)
                            .foregroundColor(.spoonBlack)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray0)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .tag(index)
            }
        }
        .padding(.horizontal, 26) 
        .frame(height: 280.adjusted)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color.clear)
    }
}
