//
//  SearchLocationFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/3/25.
//

import Foundation

import ComposableArchitecture
import CoreLocation

@Reducer
struct SearchLocationFeature {
    @ObservableState
    struct State: Equatable {
        let locationId: Int
        let locationTitle: String
        let searchedLatitude: Double?
        let searchedLongitude: Double?
        
        var pickList: [PickListCardResponse] = []
        var focusedPlaces: [CardPlace] = []
        var selectedPlace: CardPlace? = nil
        var isLoading: Bool = true
        var userLocation: CLLocation? = nil
        var selectedLocation: (latitude: Double, longitude: Double)? = nil
        var mapState: MapFeature.State = .initialState
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.locationId == rhs.locationId
        }
    }
    
    enum Action {
        case onAppear
        case fetchLocationList
        case fetchLocationListResponse(TaskResult<ResturantpickListResponse>)
        case selectPlace(CardPlace?)
        case routeToHomeScreen
        case updatePlaces(focusedPlaces: [CardPlace])
        case map(MapFeature.Action)
    }
    
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        Scope(state: \.mapState, action: \.map) {
            MapFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .concatenate(
                    .send(.fetchLocationList),
                    .send(.map(.fetchUserInfo))
                )
                
            case .fetchLocationList:
                state.isLoading = true
                return .run { [locationId = state.locationId] send in
                    let result = await TaskResult { try await homeService.fetchLocationList(locationId: locationId) }
                    await send(.fetchLocationListResponse(result))
                }
                
            case let .fetchLocationListResponse(.success(response)):
                state.isLoading = false
                state.pickList = response.zzimCardResponses
                if let firstPlace = response.zzimCardResponses.first {
                    state.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                }
                return .none
                
            case .fetchLocationListResponse(.failure):
                state.isLoading = false
                return .none
                
            case let .selectPlace(place):
                state.selectedPlace = place
                return .none
                
            case .routeToHomeScreen:
                return .none
                
            case let .updatePlaces(focusedPlaces):
                state.focusedPlaces = focusedPlaces
                if !focusedPlaces.isEmpty {
                    state.selectedPlace = focusedPlaces[0]
                } else {
                    state.selectedPlace = nil
                }
                return .none
                
            case .map(_):
                return .none
            }
        }
    }
}
