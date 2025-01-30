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
    
    @MainActor
    func fetchLocationList(locationId: Int) async {
        isLoading = true
        do {
            // Clear existing data first
            clearFocusedPlaces()
            selectedLocation = nil
            pickList = []
            
            let response = try await service.fetchLocationList(userId: Config.userId, locationId: locationId)
            
            // Set new data
            await MainActor.run {
                self.pickList = response.zzimCardResponses
                
                if let firstPlace = response.zzimCardResponses.first {
                    self.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                }
            }
        } catch {
            self.error = error
            print("Error in fetchLocationList:", error)
        }
        isLoading = false
    }

    
    func clearFocusedPlaces() {
        focusedPlaces = []
    }
}
