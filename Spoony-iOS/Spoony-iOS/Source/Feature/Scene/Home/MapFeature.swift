//
//  MapFeature.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 1/14/25.
//

import Foundation
import ComposableArchitecture
import CoreLocation

@Reducer
struct MapFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        
        var pickList: [PickListCardResponse] = []
        var filteredPickList: [PickListCardResponse] = []
        var focusedPlaces: [CardPlace] = []
        var selectedPlace: CardPlace? = nil
        
        var currentPage: Int = 0
        var isLoading: Bool = false
        var isLocationFocused: Bool = false
        var userLocation: CLLocation? = nil
        var selectedLocation: (latitude: Double, longitude: Double)? = nil
        var hasInitialLocationFocus: Bool = false // 초기 위치 포커싱 여부 추가
        
        var categories: [CategoryChip] = []
        var selectedCategories: [CategoryChip] = []
        var spoonCount: Int = 0
        
        var currentBottomSheetStyle: BottomSheetStyle = .half
        var bottomSheetHeight: CGFloat = 0
        
        var searchText: String = ""
        
        var userName: String = "스푸니"
        
        var showDailySpoonPopup: Bool = false
        var isDrawingSpoon: Bool = false
        var drawnSpoon: SpoonDrawResponse? = nil
        var spoonDrawError: String? = nil
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.pickList == rhs.pickList &&
            lhs.filteredPickList == rhs.filteredPickList &&
            lhs.focusedPlaces == rhs.focusedPlaces &&
            lhs.selectedPlace == rhs.selectedPlace &&
            lhs.currentPage == rhs.currentPage &&
            lhs.isLoading == rhs.isLoading &&
            lhs.isLocationFocused == rhs.isLocationFocused &&
            (lhs.userLocation?.coordinate.latitude == rhs.userLocation?.coordinate.latitude &&
             lhs.userLocation?.coordinate.longitude == rhs.userLocation?.coordinate.longitude) &&
            lhs.selectedLocation?.latitude == rhs.selectedLocation?.latitude &&
            lhs.selectedLocation?.longitude == rhs.selectedLocation?.longitude &&
            lhs.hasInitialLocationFocus == rhs.hasInitialLocationFocus &&
            lhs.categories == rhs.categories &&
            lhs.selectedCategories == rhs.selectedCategories &&
            lhs.spoonCount == rhs.spoonCount &&
            lhs.currentBottomSheetStyle == rhs.currentBottomSheetStyle &&
            lhs.bottomSheetHeight == rhs.bottomSheetHeight &&
            lhs.searchText == rhs.searchText &&
            lhs.userName == rhs.userName &&
            lhs.showDailySpoonPopup == rhs.showDailySpoonPopup &&
            lhs.isDrawingSpoon == rhs.isDrawingSpoon &&
            lhs.drawnSpoon == rhs.drawnSpoon &&
            lhs.spoonDrawError == rhs.spoonDrawError
        }
    }
    
    enum Action {
        case routToSearchScreen
        case routeToExploreTab
        case routeToPostView(postId: Int)
        
        case fetchPickList
        case pickListResponse(TaskResult<ResturantpickListResponse>)
        case fetchFocusedPlace(placeId: Int)
        case focusedPlaceResponse(TaskResult<MapFocusResponse>)
        case fetchLocationList(locationId: Int)
        case locationListResponse(TaskResult<ResturantpickListResponse>)
        case fetchSpoonCount
        case spoonCountResponse(TaskResult<Int>)
        case fetchCategories
        case categoriesResponse(TaskResult<[CategoryChip]>)
        
        case fetchUserInfo
        case userInfoResponse(TaskResult<UserInfoResponse>)
        
        case selectPlace(CardPlace?)
        case setCurrentPage(Int)
        case clearFocusedPlaces
        case moveToUserLocation
        case updateUserLocation(CLLocation)
        case focusToLocation(CLLocationCoordinate2D)
        case selectCategory(CategoryChip)
        case setBottomSheetStyle(BottomSheetStyle)
        case setSearchText(String)
        case applyFilters
        case toggleGPSTracking
        
        case checkDailyVisit
        case setShowDailySpoonPopup(Bool)
        case drawDailySpoon
        case spoonDrawResponse(TaskResult<SpoonDrawResponse>)
    }
    
    @Dependency(\.homeService) var homeService
    @Dependency(\.registerService) private var registerService
    @Dependency(\.myPageService) private var myPageService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeToExploreTab:
                return .none
                
            case .fetchUserInfo:
                return .run { send in
                    let result = await TaskResult {
                        try await myPageService.getUserInfo()
                    }
                    await send(.userInfoResponse(result))
                }
                
            case let .userInfoResponse(.success(userInfo)):
                state.userName = userInfo.userName
                return .none
                
            case let .userInfoResponse(.failure(error)):
                print("Error fetching user info: \(error)")
                state.userName = "사용자"
                return .none
                
            case .checkDailyVisit:
                if UserManager.shared.isFirstVisitOfDay() {
                    return .send(.setShowDailySpoonPopup(true))
                }
                return .none
                
            case let .setShowDailySpoonPopup(show):
                state.showDailySpoonPopup = show
                if !show {
                    state.drawnSpoon = nil
                    state.spoonDrawError = nil
                    state.isDrawingSpoon = false
                }
                return .none
                
            case .drawDailySpoon:
                state.isDrawingSpoon = true
                state.spoonDrawError = nil
                
                return .run { send in
                    let result = await TaskResult {
                        try await homeService.drawDailySpoon()
                    }
                    await send(.spoonDrawResponse(result))
                }
                
            case let .spoonDrawResponse(.success(response)):
                state.isDrawingSpoon = false
                state.drawnSpoon = response
                return .none
                
            case let .spoonDrawResponse(.failure(error)):
                state.isDrawingSpoon = false
                state.spoonDrawError = error.localizedDescription
                return .none
                
            case .routToSearchScreen:
                return .none
                
            case let .routeToPostView(postId):
                return .none
                
            case .fetchPickList:
                state.isLoading = true
                return .run { send in
                    let pickListResult = await TaskResult {
                        try await homeService.fetchPickList()
                    }
                    await send(.pickListResponse(pickListResult))
                }
                
            case let .pickListResponse(.success(response)):
                state.isLoading = false
                state.pickList = response.zzimCardResponses
                state.filteredPickList = response.zzimCardResponses
                return .none
                
            case let .pickListResponse(.failure(error)):
                state.isLoading = false
                print("Pick list fetch error: \(error)")
                return .none
                
            case let .fetchFocusedPlace(placeId):
                state.isLoading = true
                return .run { send in
                    let result = await TaskResult {
                        try await homeService.fetchFocusedPlace(placeId: placeId)
                    }
                    await send(.focusedPlaceResponse(result))
                }
                
            case let .fetchLocationList(locationId):
                state.isLoading = true
                return .run { send in
                    let result = await TaskResult {
                        try await homeService.fetchLocationList(locationId: locationId)
                    }
                    await send(.locationListResponse(result))
                }
                
            case let .locationListResponse(.success(response)):
                state.isLoading = false
                state.pickList = response.zzimCardResponses
                state.filteredPickList = response.zzimCardResponses
                return .none
                
            case let .locationListResponse(.failure(error)):
                state.isLoading = false
                print("Location list fetch error: \(error)")
                return .none
                
            case .fetchSpoonCount:
                return .run { send in
                    let result = await TaskResult { try await homeService.fetchSpoonCount() }
                    await send(.spoonCountResponse(result))
                }
                
            case let .spoonCountResponse(.success(count)):
                state.spoonCount = count
                return .none
                
            case let .spoonCountResponse(.failure(error)):
                print("Spoon count fetch error: \(error)")
                return .none
                
            case .fetchCategories:
                return .run { send in
                    let categoryResponse = await TaskResult {
                        try await registerService.getRegisterCategories()
                    }
                    
                    switch categoryResponse {
                    case .success(let response):
                        let categories = await TaskResult { try await response.toModel() }
                        await send(.categoriesResponse(categories))
                    case .failure(let error):
                        print("Error fetching categories: \(error)")
                        await send(.categoriesResponse(.failure(error)))
                    }
                }
                
            case let .categoriesResponse(.success(categories)):
                state.categories = categories
                state.bottomSheetHeight = BottomSheetStyle.half.height
                state.currentBottomSheetStyle = .half
                return .none
                
            case let .categoriesResponse(.failure(error)):
                print("Error processing categories: \(error)")
                return .none
                
            case let .selectPlace(place):
                state.selectedPlace = place
                return .none
                
            case let .setCurrentPage(page):
                state.currentPage = page
                return .none
                
            case .clearFocusedPlaces:
                state.focusedPlaces = []
                state.selectedPlace = nil
                state.selectedLocation = nil
                return .none

                case let .updateUserLocation(location):
                    state.userLocation = location

                if state.selectedLocation != nil || !state.focusedPlaces.isEmpty {
                        print("📍 사용자 위치 업데이트됨, 하지만 기존 선택된 위치 유지")
                        return .none
                    }
                    print("📍 사용자 위치만 업데이트됨: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    return .none
                
            case let .focusToLocation(coordinate):
                state.selectedLocation = (coordinate.latitude, coordinate.longitude)
                state.isLocationFocused = true
                return .send(.clearFocusedPlaces)
                
            case let .selectCategory(category):
                state.selectedCategories = [category]
                
                return .send(.applyFilters)
                
            case .applyFilters:
                state.filteredPickList = filterPickList(state.pickList, with: state.selectedCategories)
                return .none
                
            case let .setBottomSheetStyle(style):
                state.currentBottomSheetStyle = style
                state.bottomSheetHeight = style.height
                return .none
                
            case let .setSearchText(text):
                state.searchText = text
                return .none
                
                case let .focusedPlaceResponse(.success(response)):
                    state.isLoading = false
                    let places = response.zzimFocusResponseList.map { $0.toCardPlace() }
                    
                    if !places.isEmpty {
                        state.focusedPlaces = places
                        state.selectedPlace = places[0]
                        state.currentPage = 0
                        state.currentBottomSheetStyle = .half
                        
                        if let firstPlace = places.first {
                            if let matchingPickCard = state.pickList.first(where: { $0.placeId == firstPlace.placeId }) {
                                state.selectedLocation = (matchingPickCard.latitude, matchingPickCard.longitude)
                            }
                        }
                    } else {
                        state.focusedPlaces = []
                        state.selectedPlace = nil
                    }
                    
                    state.isLocationFocused = false
                    return .none
                
            case .toggleGPSTracking:
                if state.isLocationFocused {
                    state.isLocationFocused = false
                    state.selectedLocation = nil
                    print("📍 GPS 포커싱 해제됨")
                    return .send(.clearFocusedPlaces)
                } else {
                    // GPS 포커싱 활성화
                    guard let userLocation = state.userLocation else {
                        return .none
                    }
                    state.isLocationFocused = true
                    state.selectedLocation = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
                    print("📍 GPS 포커싱 활성화됨")
                    return .send(.clearFocusedPlaces)
                }

            case .moveToUserLocation:
                guard let userLocation = state.userLocation else {
                    return .none
                }
                
                print("📍 현재 사용자 위치: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                state.isLocationFocused = true
                state.selectedLocation = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
                
                return .send(.clearFocusedPlaces)

            case let .focusedPlaceResponse(.failure(error)):
                state.isLoading = false
                print("포커스 장소 조회 실패: \(error)")
                return .none
            }
        }
    }
    
    private func filterPickList(_ pickList: [PickListCardResponse], with categories: [CategoryChip]) -> [PickListCardResponse] {
        if categories.isEmpty || categories.contains(where: { $0.id == 0 }) {
            return pickList
        }
        
        let selectedCategoryIds = Set(categories.map { $0.id })
        
        return pickList.filter { pickCard in
            selectedCategoryIds.contains(pickCard.categoryColorResponse.categoryId)
        }
    }
}
