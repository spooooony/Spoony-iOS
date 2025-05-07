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
    
    @State private var sortIsPresented: Bool = false
    
    init(store: StoreOf<ExploreFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavigationBar
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 18) {
                    if store.state.viewType == .all {
                        filterView
                            .padding(.leading, -20)
                    }
                    
                    if store.state.viewType == .all {
                        if store.state.allList.isEmpty {
                            emptyView
                        } else {
                            listView(store.state.allList)
                                .padding(.horizontal, 20)
                        }
                    } else {
                        if store.state.followingList.isEmpty {
                            emptyView
                        } else {
                            listView(store.state.followingList)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            store.send(.viewOnAppear)
        }
        .sheet(isPresented: $store.isFilterPresented) {
            FilteringBottomSheet(
                filters: $store.filterInfo,
                isPresented: $store.isFilterPresented,
                selectedFilter: $store.selectedFilter,
                currentFilter: $store.currentFilterTypeIndex
            )
            .presentationDetents([.height(542.adjustedH)])
            .presentationCornerRadius(16)
        }
        .sheet(isPresented: $sortIsPresented) {
            SortBottomSheet(
                isPresented: $sortIsPresented,
                selectedSort: $store.selectedSort
            )
            .presentationDetents([.height(240.adjustedH)])
            .presentationCornerRadius(16)
        }
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
                            store.send(
                                .changeViewType(type),
                                animation: .spring(response: 0.3, dampingFraction: 0.7)
                            )
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
        ZStack(alignment: .trailing) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 30.adjusted, height: 0)
                    
                    ForEach(FilterButtonType.allCases, id: \.self) { type in
                        FilterCell(
                            title: getFilterTitle(type),
                            type: type,
                            selectedFilter: $store.selectedFilterButton
                        )
                        .onTapGesture {
                            store.send(.filterTapped(type))
                        }
                    }
                    
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 30.adjusted, height: 0)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.trailing, 40.adjusted)
            
            HStack(spacing: 0) {
                Image(.icFilterGray700)
                    .resizable()
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.gray100)
                    )
            )
            .onTapGesture {
                sortIsPresented = true
            }
            .spoonyShadow(style: .shadow500)
            .padding(.trailing, 20)
        }
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
        LazyVStack(spacing: 18) {
            ForEach(list) { feed in
                ExploreCell(feed: feed)
                    .onTapGesture {
                        store.send(.exploreCellTapped(feed))
                    }
            }
        }
    }
    
    private func getFilterTitle(_ type: FilterButtonType) -> String {
        guard let filterType = type.toFilterType else { return type.title }
        
        let items = store.state.selectedFilter.items(filterType)
        
        guard let firstItemTitle = items.first?.title else { return type.title }
        
        if items.count == 1 {
            return firstItemTitle
        } else {
            return "\(firstItemTitle) 외 \(items.count - 1)개"
        }
    }
}

#Preview {
    Explore(store: Store(initialState: ExploreFeature.State(), reducer: {
        ExploreFeature()
    }))
}
