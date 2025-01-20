//
//  ExploreStore.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/20/25.
//

import SwiftUI

final class ExploreStore: ObservableObject {
//    private let network: ExploreProtocol = DefatulExploreService()
    private let network: ExploreProtocol = MockExploreService()
    
    @Published private(set) var exploreList: [FeedEntity] = []
    @Published private(set) var selectedLocation: SeoulType?
    @Published private(set) var selectedFilter: FilterType = .latest
    //TODO: 위치 정보 받으면 고치기
    @Published private(set) var navigationTitle: String = "서울특별시 마포구"
    
    init() {
        Task {
            try await fetchFeedList()
        }
    }
    
    func changeLocation(location: SeoulType) {
        selectedLocation = location
        navigationTitle = "서울특별시 \(location.rawValue)"
        Task {
            try await fetchFeedList()
        }
    }
    
    func changeFilter(filter: FilterType) {
        selectedFilter = filter
        Task {
            try await fetchFeedList()
        }
    }
    
    // MARK: - Network
    @MainActor
    private func fetchFeedList() async throws {
        //TODO: userId Config에서 받아서 바꾸기
        exploreList = try await network.getUserFeed(
            userId: 1,
            location: selectedLocation?.rawValue ?? "",
            sort: selectedFilter
        )
        .map { $0.translate() }
    }
}
