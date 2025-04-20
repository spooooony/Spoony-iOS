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
    private var navigationManager: NavigationManager

    @Published private(set) var state: ExploreState = ExploreState()
    
    init(navigationManager: NavigationManager) {
        self.navigationManager = navigationManager
    }
    
    func dispatch(_ intent: ExploreIntent) {
        switch intent {
        case .onAppear:
            getSpoonCount()
            getCategoryList()
        case .navigationLocationTapped:
            state.isPresentedLocation = true
        case .locationTapped(let location):
            state.tempLocation = location
        case .selectLocationTapped:
            changeLocation()
        case .closeLocationTapped:
            state.isPresentedLocation = false
        case .filterButtontapped:
            state.isPresentedFilter = true
        case .filterTapped(let filter):
            changeFilter(filter: filter)
        case .closeFilterTapped:
            state.isPresentedFilter = false
        case .categoryTapped(let category):
            changeCategory(category: category)
        case .isPresentedLocationChanged(let newValue):
            state.isPresentedLocation = newValue
        case .isPresentedFilterChanged(let newValue):
            state.isPresentedFilter = newValue
        case .cellTapped(let feed):
            navigationManager.push(.detailView(postId: feed.postId))
        case .goRegisterButtonTapped:
            navigationManager.selectedTab = .register
        }
    }
}

extension ExploreStore {
    
    private func changeLocation() {
        guard let location = state.tempLocation else { return }
        
        state.selectedLocation = location
        getFeedList()
//        state.tempLocation = nil
        state.isPresentedLocation = false
    }
    
    private func changeFilter(filter: FilterType) {
        state.selectedFilter = filter
        getFeedList()
        state.isPresentedFilter = false
    }
    
    private func changeCategory(category: CategoryChip) {
        state.selectedCategory = category
        getFeedList()
    }
    
    private func getFeedList() {
        Task {
            try await fetchFeedList()
        }
    }

    private func getSpoonCount() {
        Task {
            try await fetchSpoonCount()
        }
    }
    
    private func getCategoryList() {
        Task {
            try await fetchCategoryList()
            await MainActor.run {
                state.selectedCategory = state.categoryList.first
            }
            try await fetchFeedList()
        }
    }
    
    // MARK: - Network
    @MainActor
    private func fetchFeedList() async throws {
        guard let category = state.selectedCategory else { return }
        
        state.exploreList = try await network.getUserFeed(
            categoryId: category.id,
            location: state.selectedLocation.rawValue,
            sort: state.selectedFilter
        )
        .toEntity()
    }
    
    @MainActor
    private func fetchCategoryList() async throws {
        state.categoryList = try await network.getCategoryList().toModel()
    }
    
    @MainActor
    private func fetchSpoonCount() async throws {
        Task {
            do {
                state.spoonCount = try await DefaultHomeService().fetchSpoonCount()
            } catch {
                print("Failed to fetch spoon count:", error)
            }
        }
    }
}
