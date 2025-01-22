//
//  ExploreStore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import SwiftUI

final class ExploreStore: ObservableObject {
        private let network: ExploreProtocol = DefaultExploreService()
//    private let network: ExploreProtocol = MockExploreService()
    
    @Published private(set) var exploreList: [FeedEntity] = []
    @Published private(set) var selectedLocation: SeoulType?
    @Published private(set) var selectedFilter: FilterType = .latest
    //TODO: 위치 정보 받으면 고치기
    @Published private(set) var navigationTitle: String = "서울특별시 마포구"
    
    @Published private(set) var categoryList: [CategoryChip] = []
    @Published private(set) var selectedCategory: CategoryChip?
    
    func changeLocation(location: SeoulType) {
        selectedLocation = location
        navigationTitle = "서울특별시 \(location.rawValue)"
        getFeedList()
    }
    
    func changeFilter(filter: FilterType) {
        selectedFilter = filter
        getFeedList()
    }
    
    func changeCategory(category: CategoryChip) {
        selectedCategory = category
        getFeedList()
    }
    
    func isSelectedCategory(category: CategoryChip) -> Bool {
        return category == selectedCategory
    }
    
    private func getFeedList() {
        Task {
            try await fetchFeedList()
        }
    }
    
    func getCategoryList() {
        Task {
            try await fetchCategoryList()
            await MainActor.run {
                selectedCategory = categoryList.first
            }
            try await fetchFeedList()
        }
    }
    
    // MARK: - Network
    @MainActor
    private func fetchFeedList() async throws {
        guard let selectedCategory else { return }
        exploreList = try await network.getUserFeed(
            userId: Config.userId,
            categoryId: selectedCategory.id,
            location: selectedLocation?.rawValue ?? "",
            sort: selectedFilter
        )
        .feedResponseList
        .map { $0.toEntity() }
    }
    
    @MainActor
    private func fetchCategoryList() async throws {
        categoryList = try await network.getCateogyList().toModel()
    }
}
