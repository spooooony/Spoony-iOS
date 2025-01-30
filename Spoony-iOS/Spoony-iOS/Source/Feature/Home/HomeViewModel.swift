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
    @Published private(set) var searchPickList: [SearchLocationResult] = []
    @Published var isLoading = false
    @Published var focusedPlaces: [CardPlace] = []
    @Published var selectedLocation: (latitude: Double, longitude: Double)?
    @Published var error: Error?
    
    init(service: HomeServiceType = DefaultHomeService()) {
        self.service = service
    }
    
    func fetchPickList() {
        Task {
            isLoading = true
            do {
                clearFocusedPlaces()
                let response = try await service.fetchPickList(userId: Config.userId)
                await MainActor.run {
                    self.pickList = response.zzimCardResponses
                    self.searchPickList = []  // 검색 결과 초기화
                }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }

    @MainActor
    func fetchLocationList(locationId: Int) async {
        print("📌 fetchLocationList called with locationId:", locationId)
        isLoading = true
        do {
            clearFocusedPlaces()

            let response = try await service.fetchLocationList(userId: Config.userId, locationId: locationId)

            await MainActor.run {  // ✅ 메인 스레드에서 실행 보장
                self.pickList = response.zzimCardResponses
                self.searchPickList = response.zzimCardResponses.map { $0.toSearchLocationResult() }

                if let firstResult = response.zzimCardResponses.first {
                    selectedLocation = (firstResult.latitude, firstResult.longitude)
                }
            }

            print("✅ Updated pickList count:", self.pickList.count)
            print("✅ Updated searchPickList count:", self.searchPickList.count)
        } catch {
            self.error = error
            print("❌ Error in fetchLocationList:", error)
        }
        isLoading = false
    }

    
    func fetchFocusedPlace(placeId: Int) {
        Task {
            isLoading = true
            do {
                // searchPickList에서 먼저 찾기
                if let selectedSearchPlace = searchPickList.first(where: { $0.placeId == placeId }) {
                    selectedLocation = (selectedSearchPlace.latitude ?? 0.0, selectedSearchPlace.longitude ?? 0.0)
                }
                // pickList에서 찾기
                else if let selectedPickPlace = pickList.first(where: { $0.placeId == placeId }) {
                    selectedLocation = (selectedPickPlace.latitude, selectedPickPlace.longitude)
                }
                
                let response = try await service.fetchFocusedPlace(userId: Config.userId, placeId: placeId)
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
