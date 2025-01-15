//
//  PlaceCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

struct PlaceCard: View {
    let placeName: String
    let visitorCount: String
    let address: String
    let images: [String]
    let title: String
    let subTitle: String
    let description: String
    
    var body: some View {
        GeometryReader { geometry in
            let containerHeight = geometry.size.height
            
            VStack(spacing: 0) {
                PlaceImagesLayout(images: images, containerHeight: containerHeight)
                
                VStack(alignment: .leading) {
                    HStack(spacing: 6) {
                        Text(placeName)
                            .font(.body1b)
                        
                        // TODO: chip으로 대체
                        HStack(spacing: 4) {
                            Image(systemName: "mug.fill")
                                .font(.system(size: containerHeight * 0.032))
                            Text("카페")
                                .font(.system(size: containerHeight * 0.038))
                        }
                        .foregroundColor(.pink400)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.pink400.opacity(0.1))
                        .cornerRadius(16)
                        
                        Spacer()
                        HStack(spacing: 4) {
                            Image(.icAddmapGray400)
                            Text(visitorCount)
                                .font(.caption2b)
                        }
                    }
                }
                .padding(containerHeight * 0.04)
                
                VStack(alignment: .leading, spacing: containerHeight * 0.016) {
                    HStack {
                        Text(title)
                            .font(.body2b)
                        Text(subTitle)
                            .font(.caption1m)
                            .foregroundColor(.gray600)
                    }
                    Text(description)
                        .font(.caption1m)
                        .foregroundColor(.spoonBlack)
                }
                .padding(containerHeight * 0.04)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray0)
                .cornerRadius(10)
                .padding(.horizontal, containerHeight * 0.04)
                .padding(.bottom, containerHeight * 0.04)
                
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
}
