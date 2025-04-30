//
//  ExploreSearchView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/17/25.
//

import SwiftUI

import ComposableArchitecture

// 임시 객체
struct SimpleUser: Identifiable, Hashable {
    let id: UUID
    let userName: String
    let regionName: String
}

struct ExploreSearchView: View {
    @Namespace private var namespace
    @Bindable private var store: StoreOf<ExploreSearchFeature>
    
    init(store: StoreOf<ExploreSearchFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .search(showBackButton: true),
                placeholder: store.state.viewType.placeholder,
                searchText: $store.searchText,
                onBackTapped: {
                    store.send(.routeToExploreScreen)
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
            }
            .customFont(.body1sb)
            .frame(maxWidth: .infinity)
            
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
        .navigationBarBackButtonHidden()
        .onAppear {
            store.send(.onAppear)
        }
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
                    store.send(.searchByRecentSearch(text))
                }
            
            Spacer()
            
            Image(.icCloseGray400)
                .resizable()
                .frame(width: 24.adjusted, height: 24.adjusted)
                .onTapGesture {
                    store.send(.recentDeleteButtonTapped(text))
                }
        }
        .frame(height: 52.adjustedH)
    }
    
    private var searchResultView: some View {
        ScrollView {
            VStack(spacing: 0) {
                if store.state.viewType == .user {
                    ForEach(store.state.userResult, id: \.id) { user in
                        userCell(user)
                    }
                } else {
                    ForEach(store.state.reviewResult, id: \.id) { feed in
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
            
            Text(store.state.viewType.emptyDescription)
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
