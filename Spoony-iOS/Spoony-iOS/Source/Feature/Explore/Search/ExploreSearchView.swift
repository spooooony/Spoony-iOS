//
//  ExploreSearchView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import SwiftUI

import ComposableArchitecture

enum ExploreSearchViewType {
    case user
    case review
    
    var description: String {
        switch self {
        case .user:
            "팔로우 하고 싶은 유저를 검색해 보세요"
        case .review:
            "원하는 키워드를 검색해 보세요"
        }
    }
    
    var placeholder: String {
        switch self {
        case .user:
            "유저 닉네임으로 검색"
        case .review:
            "리뷰 키워드로 검색"
        }
    }
    
    var emptyDescription: String {
        switch self {
        case .user:
            "정확한 닉네임을 입력해 보세요"
        case .review:
            "정확한 키워드를 입력해 보세요"
        }
    }
}

enum ExploreSearchState {
    case beforeSearch
    case recentSearch
    case searching
    case searchResult
    case noResult
}

// 임시 객체
struct SimpleUser {
    let id: UUID
    let userName: String
    let regionName: String
}

struct ExploreSearchView: View {
    @Bindable private var store: StoreOf<ExploreSearchFeature>
    
    init(store: StoreOf<ExploreSearchFeature>) {
        self.store = store
    }
    
    @State private var viewType: ExploreSearchViewType = .user
    @State private var searchState: ExploreSearchState = .searching
    
    let recentUserSearchList: [String] = ["안용은어쩌꾸저쩌구", "주리만봐", "세홍아네옆"]
    let recentReviewSearchList: [String] = ["비건", "장어덮밥", "회식"]
    
    let userResult: [SimpleUser] = [
        .init(id: UUID(), userName: "크리스탈에메랄드수정", regionName: "서울 마포구"),
        .init(id: UUID(), userName: "크리스탈에메랄드수22", regionName: "서울 마포구"),
        .init(id: UUID(), userName: "크리스탈에메랄드수1", regionName: "서울 마포구"),
    ]
    
    let reviewResult: [FeedEntity] = [
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
        VStack {
            CustomNavigationBar(
                style: .search(showBackButton: true),
                placeholder: viewType.placeholder, onBackTapped: {
                    store.send(.routeToExploreScreen)
                })
            
            // TODO: 명진샘꺼 훔쳐오기
            HStack {
                Text("유저")
                    .onTapGesture {
                        viewType = .user
                    }
                Text("리뷰")
                    .onTapGesture {
                        viewType = .review
                    }
            }
            
            switch searchState {
            case .beforeSearch:
                beforeSearchView
            case .recentSearch:
                recentSearchTextView
            case .searching:
                Spacer()
            case .searchResult:
                searchResultView
            case .noResult:
                noResultView
            }
        
        }
        .navigationBarBackButtonHidden()
    }
}

extension ExploreSearchView {
    private var beforeSearchView: some View {
        VStack(spacing: 0) {
            // TODO: Lottie
            Rectangle()
                .frame(width: 160.adjusted, height: 160.adjustedH)
                .foregroundStyle(.gray200)
                .padding(.top, 76)
            
            Text(viewType.description)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var recentSearchTextView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("최근 검색")
                    .customFont(.body2m)
                    .foregroundStyle(.gray700)
                
                Spacer()
                
                Text("전체삭제")
                    .customFont(.caption1m)
                    .foregroundStyle(.gray500)
                    .padding(.trailing, 8)
            }
            .padding(.bottom, 16)
            
            ForEach(viewType == .user ? recentUserSearchList : recentReviewSearchList, id: \.self) { text in
                resultCell(text)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }
    
    private func resultCell(_ text: String) -> some View {
        HStack {
            Text(text)
                .customFont(.body1m)
                .foregroundStyle(.gray700)
            
            Spacer()
            
            Image(.icCloseGray400)
                .resizable()
                .frame(width: 24.adjusted, height: 24.adjusted)
        }
        .frame(height: 52.adjustedH)
    }
    
    private var searchResultView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewType == .user {
                    ForEach(userResult, id: \.id) { user in
                        userCell(user)
                    }
                } else {
                    ForEach(reviewResult, id: \.id) { feed in
                        ExploreCell(feed: feed)
                            .padding(.bottom, 16)
                    }
                }
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .padding(.top, 24)
        .padding(.horizontal, 20)
    }
    
    private func userCell(_ user: SimpleUser) -> some View {
        HStack(spacing: 14) {
            Circle()
                .frame(width: 48.adjusted)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.userName)
                    .customFont(.body2m)
                Text("\(user.regionName) 스푼")
                    .customFont(.caption1m)
                    .foregroundStyle(.gray400)
                
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 64.adjustedH)
    }
    
    private var noResultView: some View {
        VStack(spacing: 0) {
            // TODO: Lottie
            Rectangle()
                .frame(width: 160.adjusted, height: 160.adjustedH)
                .foregroundStyle(.gray200)
                .padding(.top, 82)
            
            Text("검색결과가 없어요")
                .customFont(.body2sb)
                .padding(.top, 24)
            
            Text(viewType.emptyDescription)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ExploreSearchView(store: StoreOf<ExploreSearchFeature>(initialState: ExploreSearchFeature.State(), reducer: {
        ExploreSearchFeature()
    }))
}
