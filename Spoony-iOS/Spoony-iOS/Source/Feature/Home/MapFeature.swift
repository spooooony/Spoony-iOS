//
//  MapFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/6/25.
//

import Foundation
import CoreLocation
import ComposableArchitecture

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
        
        var categories: [CategoryChip] = []
        var selectedCategories: [CategoryChip] = []
        var spoonCount: Int = 0
        
        var currentBottomSheetStyle: BottomSheetStyle = .half
        var bottomSheetHeight: CGFloat = 0
        
        var searchText: String = ""
        
        // CLLocation은 자동으로 Equatable을 준수하지 않으므로 직접 구현
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.pickList == rhs.pickList &&
            lhs.filteredPickList == rhs.filteredPickList &&
            lhs.focusedPlaces == rhs.focusedPlaces &&
            lhs.selectedPlace == rhs.selectedPlace &&
            lhs.currentPage == rhs.currentPage &&
            lhs.isLoading == rhs.isLoading &&
            lhs.isLocationFocused == rhs.isLocationFocused &&
            // CLLocation은 좌표값을 비교
            (lhs.userLocation?.coordinate.latitude == rhs.userLocation?.coordinate.latitude &&
             lhs.userLocation?.coordinate.longitude == rhs.userLocation?.coordinate.longitude) &&
            lhs.selectedLocation?.latitude == rhs.selectedLocation?.latitude &&
            lhs.selectedLocation?.longitude == rhs.selectedLocation?.longitude &&
            lhs.categories == rhs.categories &&
            lhs.selectedCategories == rhs.selectedCategories &&
            lhs.spoonCount == rhs.spoonCount &&
            lhs.currentBottomSheetStyle == rhs.currentBottomSheetStyle &&
            lhs.bottomSheetHeight == rhs.bottomSheetHeight &&
            lhs.searchText == rhs.searchText
        }
    }
    
    enum Action {
        case routToSearchScreen
        case routToExploreTab
        case routToDetailView(postId: Int)
        
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
        
        case selectPlace(CardPlace?)
        case setCurrentPage(Int)
        case clearFocusedPlaces
        case moveToUserLocation
        case updateUserLocation(CLLocation)
        case selectCategory(CategoryChip)
        case setBottomSheetStyle(BottomSheetStyle)
        case setSearchText(String)
        case applyFilters
    }
    
    @Dependency(\.homeService) var homeService
    @Dependency(\.registerService) private var registerService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routToSearchScreen, .routToExploreTab, .routToDetailView:
                return .none
                
            case .fetchPickList:
                state.isLoading = true
                return .run { send in
                    let result = await TaskResult { try await homeService.fetchPickList() }
                    await send(.pickListResponse(result))
                }
                
            case let .pickListResponse(.success(response)):
                state.isLoading = false
                state.pickList = response.zzimCardResponses
                // 초기에는 필터링 없이 모든 목록 표시
                state.filteredPickList = response.zzimCardResponses
                return .none
                
            case let .pickListResponse(.failure(error)):
                state.isLoading = false
                print("Error fetching pickList: \(error)")
                return .none
                
            case let .fetchFocusedPlace(placeId):
                print("포커스 장소 조회 시작: placeId=\(placeId)")
                state.isLoading = true
                
                if let selectedPlace = state.filteredPickList.first(where: { $0.placeId == placeId }) {
                    state.selectedLocation = (selectedPlace.latitude, selectedPlace.longitude)
                }
                
                return .run { send in
                    do {
                        let response = try await homeService.fetchFocusedPlace(placeId: placeId)
                        print("포커스 장소 조회 성공: \(response.zzimFocusResponseList.count)개 장소")
                        await send(.focusedPlaceResponse(.success(response)))
                    } catch {
                        print("포커스 장소 조회 실패: \(error)")
                        await send(.focusedPlaceResponse(.failure(error)))
                    }
                }
                
            case let .fetchLocationList(locationId):
                state.isLoading = true
                return .run { send in
                    await send(.clearFocusedPlaces)
                    let result = await TaskResult { try await homeService.fetchLocationList(locationId: locationId) }
                    await send(.locationListResponse(result))
                }
                
            case let .locationListResponse(.success(response)):
                state.isLoading = false
                state.pickList = response.zzimCardResponses
                // 필터링 적용
                state.filteredPickList = filterPickList(state.pickList, with: state.selectedCategories)
                if let firstPlace = state.filteredPickList.first {
                    state.selectedLocation = (firstPlace.latitude, firstPlace.longitude)
                }
                state.isLocationFocused = false
                return .none
                
            case let .locationListResponse(.failure(error)):
                state.isLoading = false
                print("Error in fetchLocationList: \(error)")
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
                print("Error fetching spoon count: \(error)")
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
                print("기존 포커스 장소 초기화")
                state.focusedPlaces = []
                state.selectedPlace = nil
                state.selectedLocation = nil
                return .none
                
            case .moveToUserLocation:
                guard let userLocation = state.userLocation else {
                    return .none
                }
                
                state.isLocationFocused.toggle()
                
                if state.isLocationFocused {
                    state.selectedLocation = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
                    return .send(.clearFocusedPlaces)
                }
                
                return .none
                
            case let .updateUserLocation(location):
                state.userLocation = location
                return .none
                
            case let .selectCategory(category):
                if category.id == 0 {
                    state.selectedCategories = [category]
                } else {
                    if state.selectedCategories.contains(where: { $0.id == category.id }) {
                        state.selectedCategories.removeAll { $0.id == category.id }
                    } else {
                        state.selectedCategories.removeAll { $0.id == 0 }
                        state.selectedCategories.append(category)
                    }
                    
                    if state.selectedCategories.isEmpty {
                        state.selectedCategories = [CategoryChip(
                            image: "",
                            selectedImage: "",
                            title: "전체",
                            id: 0
                        )]
                    }
                }
                
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
                print("포커스 장소 응답 처리")
                state.isLoading = false
                let places = response.zzimFocusResponseList.map { $0.toCardPlace() }
                
                if !places.isEmpty {
                    state.focusedPlaces = places
                    state.selectedPlace = places[0]
                    state.currentPage = 0
                    state.currentBottomSheetStyle = .half
                } else {
                    print("포커스 장소 데이터 없음")
                    state.focusedPlaces = []
                    state.selectedPlace = nil
                }
                
                state.isLocationFocused = false
                return .none

            case let .focusedPlaceResponse(.failure(error)):
                state.isLoading = false
                print("포커스 장소 조회 실패: \(error)")
                return .none
                
            case let .routToDetailView(postId):
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

struct HomeServiceKey: DependencyKey {
    static let liveValue: HomeServiceType = DefaultHomeService()
}

extension DependencyValues {
    var homeService: HomeServiceType {
        get { self[HomeServiceKey.self] }
        set { self[HomeServiceKey.self] = newValue }
    }
}
