//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

import Lottie

struct Explore: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @StateObject private var store = ExploreStore()
    
    @State private var isPresentedLocation: Bool = false
    @State private var isPresentedFilter: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .locationDetail,
                title: store.navigationTitle,
                tappedAction: {
                    isPresentedLocation = true
                })
            
            categoryList
        
            if store.exploreList.isEmpty {
                emptyView
            } else {
                filterButton
                    .onTapGesture {
                        isPresentedFilter = true
                    }
                listView
            }
        }
        .sheet(isPresented: $isPresentedFilter) {
            FilterBottomSheet(
                isPresented: $isPresentedFilter,
                store: store
            )
            .presentationDetents([.height(250.adjustedH)])
            .presentationCornerRadius(16)
        }
        .sheet(isPresented: $isPresentedLocation) {
            LocationPickerBottomSheet(
                isPresented: $isPresentedLocation,
                store: store
            )
            .presentationDetents([.height(542.adjustedH)])
            .presentationCornerRadius(16)
        }
        .task {
            store.getCategoryList()
        }
    }
}

extension Explore {
    private var categoryList: some View {
        ScrollView(.horizontal) {
            HStack {
                Spacer()
                    .frame(width: 20.adjusted)
                ForEach(store.categoryList) { item in
                    IconChip(
                        title: item.name,
                        foodType: FoodType(title: item.name),
                        chipType: .large,
                        color: store.selectedCategory == item ? .black : .gray600
                    )
                    .onTapGesture {
                        store.changeCategory(category: item)
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
            Text(store.selectedFilter.title)
                .font(.caption1m)
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
            
            LottieView(animation: .named("lottie_explore"))
                .looping()
                .frame(width: 220.adjusted, height: 220.adjustedH)
                .padding(.top, 58)
            
            Text("아직 발견된 장소가 없어요.\n나만의 리스트를 공유해 볼까요?")
                .multilineTextAlignment(.center)
                .font(.body2m)
                .foregroundStyle(.gray500)
                .padding(.top, 30)
            
            SpoonyButton(
                style: .secondary,
                size: .xsmall,
                title: "등록하러 가기",
                disabled: .constant(false)
            ) {
                navigationManager.selectedTab = .register
            }
            .padding(.top, 18)
            
            Spacer()
        }
    }
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(store.exploreList) { list in
                    ExploreCell(feed: list)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            navigationManager.push(.detailView)
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.top, 16)
    }
}

#Preview {
    Explore()
}
