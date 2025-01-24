//
//  ExploreCell.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

struct ExploreCell: View {
    private let feed: FeedEntity
    
    init(feed: FeedEntity) {
        self.feed = feed
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 0) {
                IconChip(chip: feed.categorColorResponse.toEntity())
                
                Spacer()
                
                Image(.icAddmapGray400)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16.adjusted, height: 16.adjustedH)
                    .padding(.trailing, 4)
                Text("\(feed.zzimCount)")
                    .customFont(.caption2b)
                    .foregroundStyle(.gray500)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(feed.userName)
                    .customFont(.body2b)
                Text("서울시 \(feed.userRegion) 수저")
                    .customFont(.caption2m)
                    .foregroundStyle(.gray500)
            }
            .padding(.leading, 5)
            
            Text(feed.title)
                .customFont(.caption1m)
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
