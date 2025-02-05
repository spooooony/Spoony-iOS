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
    @Published var selectedLocation: (latitude: Double, longitude: Double)?
    @Published var error: Error?
    
    init(service: HomeServiceType = DefaultHomeService()) {
        self.service = service
    }
    
    func fetchPickList() {
        Task {
            isLoading = true
            do {
                let response = try await service.fetchPickList(userId: Config.userId)
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
                if let selectedPlace = pickList.first(where: { $0.placeId == placeId }) {
                    selectedLocation = (selectedPlace.latitude, selectedPlace.longitude)
                }
                
                let response = try await service.fetchFocusedPlace(userId: Config.userId, placeId: placeId)
                self.focusedPlaces = response.zzimFocusResponseList.map { $0.toCardPlace() }
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func fetchLocationList(locationId: Int) async {
            isLoading = true
            do {
                clearFocusedPlaces()
                selectedLocation = nil
                
                // API 호출하여 새 데이터 받아오기
                let response = try await service.fetchLocationList(
                    userId: Config.userId,
                    locationId: locationId
                )
                
                // 데이터가 성공적으로 받아와진 후에만 기존 리스트 교체
                self.pickList = response.zzimCardResponses
                
                // 첫 번째 장소가 있다면 지도 중심점 이동
                if let firstPlace = response.zzimCardResponses.first {
                    self.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                }
            } catch {
                self.error = error
                print("Error in fetchLocationList:", error)
                // 에러 발생 시 기존 데이터 유지
            }
            isLoading = false
        }
    
    func clearFocusedPlaces() {
        focusedPlaces = []
    }
}
