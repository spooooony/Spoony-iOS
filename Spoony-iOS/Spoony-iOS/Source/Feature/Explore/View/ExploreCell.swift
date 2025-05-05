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
        VStack(alignment: .leading, spacing: 16) {
            infoView
        
            photoView(feed.photoURLList.count)
            
            bottomView
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
        .background(.gray0, in: RoundedRectangle(cornerRadius: 8))
    }
}

extension ExploreCell {
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 0) {
                IconChip(chip: feed.categorColorResponse.toEntity())
                
                Spacer()
                
                Image(.icMenu)
                    .resizable()
                    .frame(width: 24.adjusted, height: 24.adjusted)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(feed.userName)
                    .customFont(.body2b)
                Text("\(feed.userRegion) 스푼")
                    .customFont(.caption2m)
                    .foregroundStyle(.gray500)
            }
            .padding(.leading, 5)
            
            Text(feed.description)
                .customFont(.caption1m)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
        }
    }
    
    @ViewBuilder
    private func photoView(_ num: Int) -> some View {
        switch num {
        case 0:
            Rectangle()
                .fill(.clear)
                .frame(width: 0, height: 0)
        case 1:
            AsyncImage(url: URL(string: "\(feed.photoURLList[0])")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundStyle(.gray200)
            }
            .frame(width: 311.adjusted, height: 311.adjustedH)
            .cornerRadius(6)
            .clipped()
        case 2:
            HStack(spacing: 7) {
                ForEach(0..<2) { num in
                    AsyncImage(url: URL(string: "\(feed.photoURLList[num])")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(.gray200)
                    }
                    .frame(width: 156.adjusted, height: 155.5.adjustedH)
                    .cornerRadius(6)
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
            }
        default:
            HStack(spacing: 7) {
                ForEach(0..<min(3, feed.photoURLList.count)) { num in
                    AsyncImage(url: URL(string: "\(feed.photoURLList[num])")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(.gray200)
                    }
                    .frame(width: 99.adjusted, height: 99.adjustedH)
                    .cornerRadius(6)
                    .frame(maxWidth: .infinity)
                    .clipped() 
                }
            }
        }
    }
    
    private var bottomView: some View {
        HStack(spacing: 4) {
            Image(.icAddmapMain400)
                .resizable()
                .frame(width: 16.adjusted, height: 16.adjusted)
            Text("\(feed.zzimCount)명이 지도에 저장했어요!")
                .customFont(.caption2m)
                .foregroundStyle(.main400)
            Spacer()

            Text(relativeDate)
                .customFont(.caption2m)
                .foregroundStyle(.gray400)
        }
    }
}

extension ExploreCell {
    private var relativeDate: String {
        let formatter = ISO8601DateFormatter()
        
        let trimmedDate = feed.createAt.split(separator: ".")[0] +
        "Z"
        guard let date = formatter.date(from: String(trimmedDate)) else {
            return "시간 오류"
        }
        
        return date.relativeTimeNamed
    }
}

#Preview {
    ExploreCell(
        feed: .init(
            id: UUID(),
            postId: 0,
            userName: "gambasgirl",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryId: 6,
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: ["", "", ""],
            createAt: "2025-04-14T14:51:35.369Z"
        )
    )
}
