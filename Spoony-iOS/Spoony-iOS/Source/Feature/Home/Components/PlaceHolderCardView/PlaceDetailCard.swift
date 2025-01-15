//
//  PlaceDetailCard.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/15/25.
//

import SwiftUI

//
//  PlaceCard.swift
//  SpoonMe
//

import SwiftUI

struct PlaceCard: View {
    let placeName: String
    let visitorCount: String
    let address: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 영역
            HStack(spacing: 8) {
                // 첫 번째 이미지
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                
                // 두 번째 이미지
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 장소 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(placeName)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(visitorCount)
                        .font(.system(size: 14))
                        .foregroundColor(.pink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.pink.opacity(0.1))
                        .cornerRadius(12)
                    
                    Spacer()
                }
                
                Text(address)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
    }
}

// Preview를 위한 extension
extension PlaceCard {
    static var preview: PlaceCard {
        PlaceCard(
            placeName: "파오리",
            visitorCount: "21",
            address: "서울특별시 마포구 와우산로 수익형"
        )
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
        PlaceCard.preview
            .padding(.horizontal, 16)
    }
}
