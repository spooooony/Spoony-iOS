//
//  HomeViewModel.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let service: HomeServiceType
    @Published private(set) var pickList: [PickListCardResponse] = []
    @Published var isLoading = false
    @Published var focusedPlaces: [CardPlace] = []
    @Published var error: Error?
    
    init(service: HomeServiceType = DefaultHomeService()) {
        self.service = service
    }
    
    func fetchPickList() {
        Task {
            isLoading = true
            do {
                let response = try await service.fetchPickList(userId: 1)
                self.pickList = response.zzimCardResponses
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func fetchFocusedPlace(placeId: Int) {
        Task {
            isLoading = true
            do {
                let response = try await service.fetchFocusedPlace(userId: 1, placeId: placeId)
                self.focusedPlaces = response.zzimFocusResponseList.map { $0.toCardPlace() }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    func clearFocusedPlaces() {
            focusedPlaces = []
        }
}
