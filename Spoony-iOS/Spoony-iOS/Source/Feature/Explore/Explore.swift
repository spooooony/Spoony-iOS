//
//  Explore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/15/25.
//

import SwiftUI

struct Explore: View {
    //임시
    private var isEmpty: Bool = false
    
    @State private var isPresentedLocation: Bool = false
    @State private var isPresentedFilter: Bool = false
    
    @State private var selectedLocation: SeoulType?
    @State private var selectedCategory: String = "전체"
    @State private var selectedFilter: FilterType = .latest
    
    private var navigationTitle: String {
        if let selectedLocation {
            return "서울특별시 \(selectedLocation.rawValue)"
        } else {
            return "서울특별시 마포구"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(style: .locationDetail, title: navigationTitle,
                                onBackTapped: {}            )
            
            categoryList
            filterButton
                .onTapGesture {
                    isPresentedFilter = true
                }
            
            if isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .sheet(isPresented: $isPresentedFilter) {
            FilterBottomSheet(
                isPresented: $isPresentedFilter,
                selectedFilter: $selectedFilter
            )
            .presentationDetents([.height(264.adjustedH)])
            .presentationCornerRadius(16)
        }
        .sheet(isPresented: $isPresentedLocation) {
            LocationPickerBottomSheet(
                isPresented: $isPresentedLocation,
                selectedRegion: $selectedLocation
            )
            .presentationDetents([.height(542.adjustedH)])
            .presentationCornerRadius(16)
        }
    }
}

extension Explore {
    private var categoryList: some View {
        
        let additionalArray: [String] = [
            "전체",
            "로컬 수저"
        ]
        let categoryArray = additionalArray + FoodType.allCases.map { $0.title }
        
        return ScrollView(.horizontal) {
            HStack {
                Spacer()
                    .frame(width: 20.adjusted)
                ForEach(categoryArray, id: \.self) { item in
                    IconChip(
                        title: item,
                        foodType: FoodType(title: item),
                        chipType: .large,
                        color: selectedCategory == item ? .black : .gray600
                    )
                    .onTapGesture {
                        selectedCategory = item
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
            Text(selectedFilter.title)
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
            RoundedRectangle(cornerRadius: 8)
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
                
            }
            .padding(.top, 18)
            
            Spacer()
        }
    }
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(1..<7) { _ in
                    ExploreCell(foodType: .american, count: 2, userName: "gambasgirl", location: "성북구 수저", description: "수제버거 육즙이 팡팡 ! 마포구에서 제일 맛있는 버거집", chipColor: .orange)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 20)
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
