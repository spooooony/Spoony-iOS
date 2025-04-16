//
//  HomeViewModel.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/21/25.
//

import Foundation
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    private let service: HomeServiceType
    @Published private(set) var pickList: [PickListCardResponse] = []
    @Published var isLoading = false
    @Published var focusedPlaces: [CardPlace] = []
    @Published var selectedLocation: (latitude: Double, longitude: Double)?
    @Published var error: Error?
    @Published var isLocationFocused: Bool = false
    @Published var userLocation: CLLocation?
    
    init(service: HomeServiceType = DefaultHomeService()) {
        self.service = service
    }
    
    func fetchPickList() {
        Task {
            isLoading = true
            do {
                let response = try await service.fetchPickList()
                print("Received pickList response: \(response)")
                print("Number of items: \(response.zzimCardResponses.count)")
                self.pickList = response.zzimCardResponses
                print("Updated pickList count: \(self.pickList.count)")
            } catch {
                self.error = error
                print("Error fetching pickList: \(error)")
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
                
                let response = try await service.fetchFocusedPlace(placeId: placeId)
                self.focusedPlaces = response.zzimFocusResponseList.map { $0.toCardPlace() }
                
                self.isLocationFocused = false
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
            
            let response = try await service.fetchLocationList(locationId: locationId)
            self.pickList = response.zzimCardResponses
        
            if let firstPlace = response.zzimCardResponses.first {
                self.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
            }
            
            self.isLocationFocused = false
        } catch {
            self.error = error
            print("Error in fetchLocationList:", error)
        }
        isLoading = false
    }
    
    func clearFocusedPlaces() {
        focusedPlaces = []
        selectedLocation = nil
    }
    
    func moveToUserLocation() {
        guard let userLocation = userLocation else {
            requestLocationAccess()
            return
        }
        selectedLocation = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        isLocationFocused = true
        clearFocusedPlaces()
    }
    
    private func requestLocationAccess() {
        let locationManager = CLLocationManager()
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied")
        default:
            break
        }
    }
    
    func updateUserLocation(_ location: CLLocation) {
        Task { @MainActor in
            userLocation = location
        }
    }
}
