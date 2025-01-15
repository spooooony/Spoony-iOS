//
//  ExploreCell.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

struct ExploreCell: View {
    let foodType: FoodType
    let count: Int
    let userName: String
    let location: String
    let description: String
    let chipColor: ChipColorType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 0) {
                IconChip(
                    title: foodType.title,
                    foodType: foodType,
                    chipType: .small,
                    color: chipColor
                )
                
                Spacer()
                
                Image(.icAddmapGray400)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16.adjusted, height: 16.adjustedH)
                    .padding(.trailing, 4)
                Text("\(count)")
                    .font(.caption2b)
                    .foregroundStyle(.gray500)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(userName)
                    .font(.body2b)
                    .padding(.leading, 5)
                Text(location)
                    .font(.caption2m)
                    .foregroundStyle(.gray500)
            }
            
            Text(description)
                .font(.caption1m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 12)
        .padding(.top, 15)
        .padding(.bottom, 18)
        .background(.gray0, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ExploreCell(
        foodType: .american,
        count: 10,
        userName: "gambasgirl",
        location: "성북구 수저",
        description: "수제버거 육즙이 팡팡 ! 마포구에서 제일 맛있는 버거집",
        chipColor: .orange
    )
}
