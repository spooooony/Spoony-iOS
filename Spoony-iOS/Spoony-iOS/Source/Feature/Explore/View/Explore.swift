//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

import ComposableArchitecture
import Lottie

struct Explore: View {
    @Namespace private var namespace
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
        HStack(spacing: 0) {
            ForEach(ExploreViewType.allCases, id: \.self) { type in
                VStack(spacing: 9.adjustedH) {
                    Text(type.title)
                        .foregroundStyle(store.state.viewType == type ? .main400 : .gray300)
                        .onTapGesture {
                            store.send(.changeViewType(type))
                        }
                    
                    Rectangle()
                        .fill(.main400)
                        .frame(height: 2.adjustedH)
                        .isHidden(store.state.viewType != type)
                        .matchedGeometryEffect(id: "underline", in: namespace)
                }
                // TODO: 글자 크기에 맞추기
                .frame(width: 50)
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
        .animation(
            .easeInOut(duration: 0.25),
            value: store.state.viewType
        )
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
