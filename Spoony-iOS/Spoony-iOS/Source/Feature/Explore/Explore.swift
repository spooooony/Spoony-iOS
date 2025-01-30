//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

import Lottie

struct Explore: View {
    @StateObject var store: ExploreStore
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            CustomNavigationBar(
                style: .locationDetail,
                title: "서울특별시 \(store.state.selectedLocation.rawValue)",
                spoonCount: store.state.spoonCount,
                tappedAction: {
                    store.dispatch(.navigationLocationTapped)
                })
            
            categoryList
        
            if store.state.exploreList.isEmpty {
                emptyView
            } else {
                filterButton
                    .onTapGesture {
                        store.dispatch(.filterButtontapped)
                    }
                listView
            }
        }
        .sheet(isPresented: Binding(get: {
            store.state.isPresentedFilter
        }, set: { newValue in
            store.dispatch(.isPresentedFilterChanged(newValue))
        })) {
            FilterBottomSheet(store: store)
            .presentationDetents([.height(250.adjustedH)])
            .presentationCornerRadius(16)
        }
        .sheet(isPresented: Binding(get: {
            store.state.isPresentedLocation
        }, set: { newValue in
            store.dispatch(.isPresentedLocationChanged(newValue))
        })) {
            LocationPickerBottomSheet(store: store)
            .presentationDetents([.height(542.adjustedH)])
            .presentationCornerRadius(16)
        }
        .task {
            store.dispatch(.onAppear)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

extension Explore {
    private var categoryList: some View {
        ScrollView(.horizontal) {
            HStack {
                Spacer()
                    .frame(width: 20.adjusted)
                ForEach(store.state.categoryList) { item in
                    ExploreCategoryChip(category: item, selected: item == store.state.selectedCategory)
                    .onTapGesture {
                        store.dispatch(.categoryTapped(item))
                    }
                }
                Spacer()
                    .frame(width: 20.adjusted)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var filterButton: some View {
        HStack(spacing: 2) {
            Spacer()
            Text(store.state.selectedFilter.title)
                .customFont(.caption1m)
                .foregroundStyle(.gray700)
            Image(.icFilterGray700)
                .resizable()
                .scaledToFit()
                .frame(width: 16.adjusted, height: 16.adjustedH)
        }
        .padding(.top, 16)
        .padding(.trailing, 20)
    }
    
    private var emptyView: some View {
        VStack(spacing: 0) {
            
            LottieView(animation: .named("lottie_empty_explore"))
                .looping()
                .frame(width: 220.adjusted, height: 220.adjustedH)
                .padding(.top, 98)
            
            Text("아직 발견된 장소가 없어요.\n나만의 리스트를 공유해 볼까요?")
                .multilineTextAlignment(.center)
                .customFont(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 30)
            
            SpoonyButton(
                style: .secondary,
                size: .xsmall,
                title: "등록하러 가기",
                disabled: .constant(false)
            ) {
                store.dispatch(.goRegisterButtonTapped)
            }
            .padding(.top, 18)
            
            Spacer()
        }
    }
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(store.state.exploreList) { list in
                    ExploreCell(feed: list)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            store.dispatch(.cellTapped(list))
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.top, 16)
    }
}
