//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

import Lottie

enum ExploreViewType {
    case all
    case following
    
    var emptyDescription: String {
        switch self {
        case .all:
            "아직 발견된 장소가 없어요.\n나만의 리스트를 공유해 볼까요?"
        case .following:
            "아직 팔로우 한 유저가 없어요.\n관심 있는 유저들을 팔로우해보세요."
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .all:
            "등록하러 가기"
        case .following:
            "검색하러 가기"
        }
    }
    
    var lottieImage: String {
        switch self {
        case .all:
            "lottie_empty_explore"
        case .following:
            "lottie_empty_explore"
        }
    }
}

enum FilterButtonType: CaseIterable {
    case filter
    case local
    case sort
    case category
    case location
    case age
    
    var title: String {
        switch self {
        case .filter:
            "필터"
        case .local:
            "로컬 리뷰"
        case .sort:
            "최신순"
        case .category:
            "카테고리"
        case .location:
            "지역"
        case .age:
            "연령대"
        }
    }
    
    var isLeadingIcon: Bool {
        switch self {
        case .filter:
            true
        default:
            false
        }
    }
    
    var isTrailingIcon: Bool {
        switch self {
        case .filter, .local:
            false
        default:
            true
        }
    }
}

struct Explore: View {
    @State private var viewType: ExploreViewType = .all
    let list: [FeedEntity] = [
        .init(
            id: UUID(),
            postId: 0,
            userName: "gambasgirl",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: [""],
            createAt: "2025-04-14T12:21:49.524Z"
        ),
        .init(
            id: UUID(),
            postId: 0,
            userName: "gambasgirl",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: ["", ""],
            createAt: "2025-04-14T12:21:49.524Z"
        ),
        .init(
            id: UUID(),
            postId: 0,
            userName: "gambasgirl",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: ["", "", ""],
            createAt: "2025-04-14T12:21:49.524Z"
        )
    ]
    
    let follwingList: [FeedEntity] = [
        .init(
            id: UUID(),
            postId: 0,
            userName: "thingjin",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: [""],
            createAt: "2025-04-14T12:21:49.524Z"
        ),
        .init(
            id: UUID(),
            postId: 0,
            userName: "thingjin",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: ["", ""],
            createAt: "2025-04-14T12:21:49.524Z"
        ),
        .init(
            id: UUID(),
            postId: 0,
            userName: "thingjin",
            userRegion: "서울 성북구",
            description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어지는 어쩌구 저쩌구 어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구어쩌구 저쩌구",
            categorColorResponse: .init(
                categoryName: "양식",
                iconUrl: "",
                iconTextColor: "",
                iconBackgroundColor: ""
            ),
            zzimCount: 17,
            photoURLList: ["", "", ""],
            createAt: "2025-04-14T12:21:49.524Z"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 18) {
                    filterView
                    
                    if list.isEmpty {
                        emptyView
                    } else {
                        switch viewType {
                        case .all:
                            listView(list)
                        case .following:
                            listView(follwingList)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 20)
    }
}

extension Explore {
    private var customNavigationBar: some View {
        // TODO: 명진샘 애니메이션 훔치기
        HStack {
            Text("전체")
                .foregroundStyle(viewType == .all ? .main400 : .gray300)
                .onTapGesture {
                    viewType = .all
                }
            Text("팔로잉")
                .foregroundStyle(viewType == .following ? .main400 : .gray300)
                .onTapGesture {
                    viewType = .following
                }
            Spacer()
            Image(.icSearchGray600)
                .resizable()
                .frame(width: 19.adjusted, height: 19.adjusted)
        }
        .customFont(.title3sb)
        .padding(.top, 12)
    }
    
    private var filterView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 12.adjusted, height: 0)
                
                ForEach(FilterButtonType.allCases, id: \.self) { type in
                    FilterCell(
                        isLeadingIcon: type.isLeadingIcon,
                        isTrailingIcon: type.isTrailingIcon,
                        text: type.title
                    )
                    .onTapGesture {
                        // 필터 바텀시트 올리기
                    }
                }
                
                Rectangle()
                    .fill(.clear)
                    .frame(width: 12.adjusted, height: 0)
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -20)
    }
    
    private var emptyView: some View {
        
        VStack(spacing: 0) {
            
            LottieView(animation: .named(viewType.lottieImage))
                .looping()
                .frame(width: 220.adjusted, height: 220.adjustedH)
                .padding(.top, 98)
            
            Text(viewType.emptyDescription)
                .multilineTextAlignment(.center)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 30)
            
            SpoonyButton(
                style: .secondary,
                size: .xsmall,
                title: viewType.buttonTitle,
                disabled: .constant(false)
            ) {
            }
            .padding(.top, 18)
            
            Spacer()
        }
    }
    
    private func listView(_ list: [FeedEntity]) -> some View {
        ForEach(list) { list in
            ExploreCell(feed: list)
        }
    }
}

#Preview {
    Explore()
}
