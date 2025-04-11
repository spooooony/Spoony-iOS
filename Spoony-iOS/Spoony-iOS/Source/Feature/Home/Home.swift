//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
import ComposableArchitecture

struct Home: View {
//    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = HomeViewModel(service: DefaultHomeService())
    private let store: StoreOf<MapFeature>
    @State private var isBottomSheetPresented = true
    @State private var searchText = ""
    @State private var selectedPlace: CardPlace?
    @State private var currentPage = 0
    @State private var spoonCount: Int = 0
    @State private var selectedCategories: [CategoryChip] = []
    @State private var categories: [CategoryChip] = []
    private let restaurantService: HomeServiceType
    private let registerService: RegisterServiceType
    
    init(store: StoreOf<MapFeature>,
         restaurantService: HomeServiceType = DefaultHomeService(),
         registerService: RegisterServiceType = RegisterService()) {
        self.store = store
        self.restaurantService = restaurantService
        self.registerService = registerService
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            NMapView(viewModel: viewModel, selectedPlace: $selectedPlace)
                .edgesIgnoringSafeArea(.all)
                .onChange(of: viewModel.focusedPlaces) { _, newPlaces in
                    if !newPlaces.isEmpty {
                        selectedPlace = newPlaces[0]
                    } else {
                        selectedPlace = nil
                    }
                }
            
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .searchContent,
                    searchText: $searchText,
                    spoonCount: spoonCount,
                    tappedAction: {
                        store.send(.routToSearchScreen)
//                        navigationManager.push(.searchView)
                    }
                )
                .frame(height: 56.adjusted)
                
                // 카테고리 버튼 영역 (일자로 배치)
                HStack(spacing: 8) {
                    if categories.isEmpty {
                        // 로딩 중일 때 플레이스홀더 표시
                        ForEach(0..<4, id: \.self) { _ in
                            CategoryChipsView(category: CategoryChip.placeholder)
                                .redacted(reason: .placeholder)
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // 일단 하드코딩 박기ㅋㅋ
                                CategoryChipsView(
                                    category: CategoryChip(
                                        image: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/category/icons/all_color.png",
                                        selectedImage: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/category/icons/all_white.png",
                                        title: "전체",
                                        id: 0
                                    ),
                                    isSelected: selectedCategories.isEmpty || selectedCategories.contains { $0.id == 0 }
                                )
                                .onTapGesture {
                                    // 전체를 선택하면 다른 선택을 모두 해제
                                    selectedCategories = []
                                }
                                
                                ForEach(categories, id: \.id) { category in
                                    CategoryChipsView(
                                        category: category,
                                        isSelected: selectedCategories.contains { $0.id == category.id }
                                    )
                                    .onTapGesture {
                                        handleCategorySelection(category)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                Spacer()
            }
            
            Group {
                if !viewModel.focusedPlaces.isEmpty {
                    PlaceCard(
                        places: viewModel.focusedPlaces,
                        currentPage: $currentPage
                    )
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom))
                } else {
                    if !viewModel.pickList.isEmpty {
                        BottomSheetListView(viewModel: viewModel, store: store)
                    } else {
                        FixedBottomSheetView(store: store)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            isBottomSheetPresented = true
            do {
                spoonCount = try await restaurantService.fetchSpoonCount()
                viewModel.fetchPickList()
                
                let categoryResponse = try await registerService.getRegisterCategories()
                categories = try await categoryResponse.toModel()
                
               
            } catch {
                print("Failed to fetch data:", error)
            }
        }
    }
    
    // 카테고리 선택 처리 메서드
    private func handleCategorySelection(_ category: CategoryChip) {
        if selectedCategories.contains(where: { $0.id == category.id }) {
            selectedCategories.removeAll { $0.id == category.id }
        } else {
            selectedCategories = [category]
        }
        
        if !selectedCategories.isEmpty {
            let categoryId = selectedCategories[0].id
            print("Selected category: \(categoryId)")
            // viewModel.filterByCategory(categoryId: categoryId)
        } else {
            // 선택 해제 시 모든 항목 표시
            // viewModel.resetFilters()
        }
    }
}

#Preview {
    Home(store: Store(initialState: .initialState) {
        MapFeature()
    }).environmentObject(NavigationManager())
}
