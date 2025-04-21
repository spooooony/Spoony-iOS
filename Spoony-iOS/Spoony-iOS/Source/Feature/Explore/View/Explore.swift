//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

import ComposableArchitecture
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
    @Bindable private var store: StoreOf<ExploreFeature>
    
    init(store: StoreOf<ExploreFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 18) {
                    filterView
                    
                    if store.state.viewType == .all {
                        if store.state.allList.isEmpty {
                            emptyView
                        } else {
                            listView(store.state.allList)
                        }
                    } else {
                        if store.state.followingList.isEmpty {
                            emptyView
                        } else {
                            listView(store.state.followingList)
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
                .foregroundStyle(store.state.viewType == .all ? .main400 : .gray300)
                .onTapGesture {
                    store.send(.changeViewType(.all))
                }
            Text("팔로잉")
                .foregroundStyle(store.state.viewType == .following ? .main400 : .gray300)
                .onTapGesture {
                    store.send(.changeViewType(.following))
                }
            Spacer()
            Image(.icSearchGray600)
                .resizable()
                .frame(width: 19.adjusted, height: 19.adjusted)
                .onTapGesture {
                    store.send(.searchButtonTapped)
                }
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
                    FilterCell(type: type, selectedFilter: $store.selectedFilter)
                    .onTapGesture {
                        // 필터 바텀시트 올리기
                        store.send(.filterTapped)
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
            
            LottieView(animation: .named(store.state.viewType.lottieImage))
                .looping()
                .frame(width: 220.adjusted, height: 220.adjustedH)
                .padding(.top, 98)
            
            Text(store.state.viewType.emptyDescription)
                .multilineTextAlignment(.center)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 30)
            
            SpoonyButton(
                style: .secondary,
                size: .xsmall,
                title: store.state.viewType.buttonTitle,
                disabled: .constant(false)
            ) {
                store.send(.goButtonTapped)
            }
            .padding(.top, 18)
            
            Spacer()
        }
    }
    
    private func listView(_ list: [FeedEntity]) -> some View {
        ForEach(list) { feed in
            ExploreCell(feed: feed)
                .onTapGesture {
                    store.send(.exploreCellTapped(feed))
                }
        }
    }
}

#Preview {
    Explore(store: Store(initialState: ExploreFeature.State(), reducer: {
        ExploreFeature()
    }))
}
