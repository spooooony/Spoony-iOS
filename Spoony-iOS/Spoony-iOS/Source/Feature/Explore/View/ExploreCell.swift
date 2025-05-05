//
//  ExploreCell.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

struct ExploreCell: View {
    private let feed: FeedEntity
    @State private var showOptions: Bool = false
    
    var onDelete: ((Int) -> Void)?
    var onEdit: ((FeedEntity) -> Void)?
    
    init(feed: FeedEntity, onDelete: ((Int) -> Void)? = nil, onEdit: ((FeedEntity) -> Void)? = nil) {
        self.feed = feed
        self.onDelete = onDelete
        self.onEdit = onEdit
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
        .reviewDropdownMenu(
            isShowing: $showOptions,
            onEdit: {
                onEdit?(feed)
            },
            onDelete: {
                onDelete?(feed.postId)
            }
        )
    }
}

extension ExploreCell {
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 0) {
                IconChip(chip: feed.categorColorResponse.toEntity())
                
                Spacer()
                
                if onDelete != nil || onEdit != nil {
                    Button(action: {
                        withAnimation {
                            showOptions.toggle()
                        }
                    }) {
                        Image(.icMenu)
                            .resizable()
                            .frame(width: 24.adjusted, height: 24.adjusted)
                            .contentShape(Rectangle())
                    }
                    .id("menuButton-\(feed.id)")
                    .environment(\.reviewCellID, feed.id.uuidString)
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Image(.icMenu)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjusted)
                }
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
            
        case 1:
            AsyncImage(url: URL(string: "\(feed.photoURLList[0])")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundStyle(.gray200)
            }
            .frame(height: 311.adjustedH)
            .frame(maxWidth: .infinity)
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
                    .frame(height: 155.adjustedH)
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
                    .frame(height: 99.adjustedH)
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
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: feed.createAt) else {
            return "시간 오류"
        }
        
        return date.relativeTimeNamed
    }
}
