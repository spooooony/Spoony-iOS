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
    @State private var isDropdown: Bool = false
    
    private var onDelete: ((Int) -> Void)?
    private var onEdit: ((FeedEntity) -> Void)?
    private var onReport: ((FeedEntity) -> Void)?
    
    init(
        feed: FeedEntity,
        onDelete: ((Int) -> Void)? = nil,
        onEdit: ((FeedEntity) -> Void)? = nil,
        onReport: ((FeedEntity) -> Void)? = nil
    ) {
        self.feed = feed
        self.onDelete = onDelete
        self.onEdit = onEdit
        self.onReport = onReport
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
        .overlay(alignment: .topTrailing, content: {
            dropDownView
        })
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    isDropdown = false
                    showOptions = false
                }
        )
        .onAppear {
            isDropdown = false
            showOptions = false
        }
    }
}

extension ExploreCell {
    private var infoView: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 0) {
                IconChip(chip: feed.categorColorResponse.toEntity())
                
                Spacer()
                
                Button(action: {
                    if onDelete != nil || onEdit != nil {
                        withAnimation {
                            showOptions.toggle()
                        }
                    } else {
                        isDropdown.toggle()
                    }
                    print("tapped")
                }) {
                    Image(.icMenu)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjusted)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .zIndex(0)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(feed.userName)
                    .customFont(.body2b)
                
                if let region = feed.userRegion {
                    Text("서울 \(region) 스푼")
                        .customFont(.caption2m)
                        .foregroundStyle(.gray500)
                }
                
                Spacer()
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
    
    private var dropDownView: some View {
        Group {
            if isDropdown {
                DropDownMenu(
                    items: ["신고하기"],
                    isPresented: $isDropdown
                ) { _ in
                    onReport?(feed)
                }
                .frame(alignment: .topTrailing)
                .padding(.top, 48.adjustedH)
                .padding(.trailing, 20.adjusted)
            }
        }
    }
}

extension ExploreCell {
    private var relativeDate: String {
        let formatter = ISO8601DateFormatter()
        
        let trimmedDate = feed.createAt.split(separator: ".")[0] + "Z"
        guard let date = formatter.date(from: String(trimmedDate)) else {
            return "시간 오류"
        }
        
        return date.relativeTimeNamed
    }
}
