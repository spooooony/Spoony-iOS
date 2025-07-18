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
            lhs.locationId == rhs.locationId &&
            lhs.locationTitle == rhs.locationTitle &&
            lhs.searchedLatitude == rhs.searchedLatitude &&
            lhs.searchedLongitude == rhs.searchedLongitude
        }
        
        init(locationId: Int,
             locationTitle: String,
             searchedLatitude: Double? = nil,
             searchedLongitude: Double? = nil) {
            self.locationId = locationId
            self.locationTitle = locationTitle
            self.searchedLatitude = searchedLatitude
            self.searchedLongitude = searchedLongitude
            
            if let lat = searchedLatitude, let lng = searchedLongitude {
                self.selectedLocation = (latitude: lat, longitude: lng)
                self.mapState.selectedLocation = (latitude: lat, longitude: lng)
                self.mapState.isLocationFocused = false
                print("📍 SearchLocationFeature 초기화: 검색된 위치 \(lat), \(lng)")
            } else {
                self.mapState.isLocationFocused = false
                print("📍 SearchLocationFeature 초기화: 검색된 위치 정보 없음")
            }
        }
    }
    
    enum Action {
        case onAppear
        case fetchLocationList
        case fetchLocationListResponse(TaskResult<ResturantpickListResponse>)
        case selectPlace(CardPlace?)
        case routeToHomeScreen
        case routeToPostDetail(postId: Int)
        case routeToExploreTab  
        case updatePlaces(focusedPlaces: [CardPlace])
        case setSelectedLocation(latitude: Double, longitude: Double)
        case forceMoveCameraToSearchLocation
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
                // 수정: onAppear 시 검색된 위치로 설정
                if let lat = state.searchedLatitude, let lng = state.searchedLongitude {
                    state.selectedLocation = (latitude: lat, longitude: lng)
                    state.mapState.selectedLocation = (latitude: lat, longitude: lng)
                    state.mapState.isLocationFocused = false
                    print("📍 onAppear: 검색된 위치로 설정 \(lat), \(lng)")
                }
                
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
                
                // 수정: 검색된 위치가 있으면 우선적으로 사용
                if state.selectedLocation == nil {
                    if let searchedLat = state.searchedLatitude,
                       let searchedLng = state.searchedLongitude {
                        state.selectedLocation = (searchedLat, searchedLng)
                        state.mapState.selectedLocation = (searchedLat, searchedLng)
                        state.mapState.isLocationFocused = false
                        print("📍 fetchLocationListResponse: 검색된 위치로 재설정 \(searchedLat), \(searchedLng)")
                    } else if let firstPlace = response.zzimCardResponses.first {
                        state.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                        state.mapState.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                        state.mapState.isLocationFocused = false
                        print("📍 fetchLocationListResponse: 첫 번째 장소로 설정")
                    }
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
                
            case .routeToPostDetail:
                return .none
                
            case .routeToExploreTab:  // 새로 추가된 액션 처리
                print("🟡 [SearchLocationFeature] .routeToExploreTab 액션 받음")
                return .none
                
            case let .updatePlaces(focusedPlaces):
                state.focusedPlaces = focusedPlaces
                if !focusedPlaces.isEmpty {
                    state.selectedPlace = focusedPlaces[0]
                } else {
                    state.selectedPlace = nil
                }
                return .none
                
            case let .setSelectedLocation(latitude, longitude):
                state.selectedLocation = (latitude: latitude, longitude: longitude)
                state.mapState.selectedLocation = (latitude: latitude, longitude: longitude)
                print("📍 setSelectedLocation: \(latitude), \(longitude)")
                return .none
                
            case .forceMoveCameraToSearchLocation:
                // 수정: 강제로 검색된 위치로 카메라 이동
                if let lat = state.searchedLatitude, let lng = state.searchedLongitude {
                    state.selectedLocation = (latitude: lat, longitude: lng)
                    state.mapState.selectedLocation = (latitude: lat, longitude: lng)
                    state.mapState.isLocationFocused = false
                    print("📍 forceMoveCameraToSearchLocation: \(lat), \(lng)")
                }
                return .none
                
            case .map(.routeToExploreTab):  // MapFeature에서 오는 액션 전파
                print("🟡 [SearchLocationFeature] map의 .routeToExploreTab 액션 전파")
                return .send(.routeToExploreTab)
                
            case .map(_):
                return .none
            }
        }
    }
}
