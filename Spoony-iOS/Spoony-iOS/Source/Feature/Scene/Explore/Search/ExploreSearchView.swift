//
//  ExploreSearchView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import SwiftUI

import ComposableArchitecture

struct ExploreSearchView: View {
    @Namespace private var namespace
    @Bindable private var store: StoreOf<ExploreSearchFeature>
    @FocusState private var isFocused: Bool
    
    init(store: StoreOf<ExploreSearchFeature>) {
        self.store = store
    }
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                CustomNavigationBar(
                    style: .search(showBackButton: true),
                    placeholder: store.state.viewType.placeholder,
                    searchText: $store.searchText,
                    onBackTapped: {
                        store.send(.delegate(.routeToPreviousScreen))
                    }, tappedAction: {
                        store.send(.onSubmit)
                    }
                )
                
                HStack(spacing: 0) {
                    ForEach(ExploreSearchViewType.allCases, id: \.self) { type in
                        VStack(spacing: 0) {
                            Text(type.title)
                                .foregroundStyle(store.state.viewType == type ? .main400 : .gray400)
                                .onTapGesture {
                                    store.send(
                                        .changeViewType(type),
                                        animation: .spring(response: 0.3, dampingFraction: 0.7)
                                    )
                                }
                                .frame(maxWidth: .infinity)
                            
                            Rectangle()
                                .fill(.main400)
                                .frame(height: 2.adjustedH)
                                .isHidden(store.state.viewType != type)
                                .matchedGeometryEffect(id: "underline", in: namespace)
                                .padding(.top, 9)
                            
                            Rectangle()
                                .fill(.gray100)
                                .frame(height: 6.adjustedH)
                        }
                    }
                    .customFont(.body1sb)
                    .frame(maxWidth: .infinity)
                }
                
                switch store.state.searchState {
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
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .focused($isFocused)
        .background(.white)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            if store.state.searchState == .beforeSearch {
                isFocused = true
            }
            store.send(.onAppear)
        }
        .alertView(
            isPresented: $store.isAlertPresented,
            alertType: store.alertType,
            alert: store.alert,
            confirmAction: {
                store.send(.confirmDeleteReview)
            },
            afterAction: nil
        )
        .transaction {
            $0.disablesAnimations = true
        }
    }
}

extension ExploreSearchView {
    private var beforeSearchView: some View {
        VStack(spacing: 0) {
            Image(.imageExploreSearchEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 160.adjusted, height: 160.adjustedH)
                .foregroundStyle(.gray200)
                .padding(.top, 76)
            
            Text(store.state.viewType.description)
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
                    .onTapGesture {
                        store.send(.allDeleteButtonTapped)
                    }
            }
            .padding(.bottom, 16)
            
            ForEach(store.state.viewType.recentSearches, id: \.self) { text in
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
                .onTapGesture {
                    hideKeyboard()
                    store.send(.searchByRecentSearch(text))
                }
            
            Spacer()
            
            Image(.icCloseGray400)
                .resizable()
                .frame(width: 24.adjusted, height: 24.adjusted)
                .onTapGesture {
                    hideKeyboard()
                    store.send(.recentDeleteButtonTapped(text))
                }
        }
        .frame(height: 52.adjustedH)
    }
    
    private var searchResultView: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                switch store.state.viewType {
                case .user:
                    ForEach(store.state.userResult, id: \.id) { user in
                        userCell(user)
                            .onTapGesture {
                                if user.isMine {
                                    store.send(.delegate(.routeToMyProfileScreen))
                                } else {
                                    store.send(.delegate(.routeToUserProfileScreen(user.id)))
                                }
                            }
                    }
                case .review:
                    ForEach(store.state.reviewResult, id: \.id) { feed in
                        if feed.isMine {
                            myExploreCell(feed)
                                .onTapGesture {
                                    store.send(.delegate(.routeToPostScreen(feed)))
                                }
                        } else {
                            otherExploreCell(feed)
                                .onTapGesture {
                                    store.send(.delegate(.routeToPostScreen(feed)))
                                }
                        }
                        
                    }
                }
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, 20)
    }
    
    private func userCell(_ user: SimpleUser) -> some View {
        HStack(spacing: 14) {
            AsyncImage(url: URL(string: user.profileImage)) { phase in
                if let image = phase.image {
                    image.resizable()
                } else if phase.error != nil {
                    Circle()
                        .fill(Color.gray200)
                } else {
                    Circle()
                        .fill(Color.gray200)
                }
            }
            .clipShape(Circle())
            .frame(width: 60.adjusted, height: 60.adjustedH)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.userName)
                    .customFont(.body2m)
                if let region = user.regionName {
                    Text("\(region) 스푼")
                        .customFont(.caption1m)
                        .foregroundStyle(.gray400)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 64.adjustedH)
    }
    
    private var noResultView: some View {
        VStack(spacing: 0) {
            Image(.imageExploreSearchEmpty)
                .resizable()
                .scaledToFit()
                .frame(width: 160.adjusted, height: 160.adjustedH)
                .foregroundStyle(.gray200)
                .padding(.top, 82)
            
            Text("검색결과가 없어요")
                .customFont(.body2sb)
                .padding(.top, 24)
            
            Text(store.state.viewType.emptyDescription)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func myExploreCell(_ feed: FeedEntity) -> some View {
        ExploreCell(
            feed: feed,
            onDelete: { _ in
                store.send(.deleteMyReview(feed.postId))
            },
            onEdit: { feed in
                store.send(.delegate(.routeToEditReviewScreen(feed.postId)))
            }
        )
    }
    
    private func otherExploreCell(_ feed: FeedEntity) -> some View {
        ExploreCell(
            feed: feed,
            onReport: { feed in
                store.send(.delegate(.routeToPostReportScreen(feed.postId)))
            }
        )
    }
}

#Preview {
    ExploreSearchView(store: StoreOf<ExploreSearchFeature>(initialState: ExploreSearchFeature.State(), reducer: {
        ExploreSearchFeature()
    }))
}
