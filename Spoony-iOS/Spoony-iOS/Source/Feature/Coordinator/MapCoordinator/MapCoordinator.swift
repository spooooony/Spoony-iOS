//
//  MapCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/6/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum MapScreen {
    case map(MapFeature)
    case search(SearchFeature)
    case searchLocation(SearchLocationFeature)
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.map(.initialState), embedInNavigationView: true)])
        
        var routes: [Route<MapScreen.State>]
        var selectedLocationId: Int?
    }
    
    enum Action {
        case router(IndexedRouterActionOf<MapScreen>)
        case locationSelected(Int)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .map(.routToSearchScreen))):
                state.routes.push(.search(.initialState))
                return .none
                
            case let .locationSelected(locationId):
                state.selectedLocationId = locationId
                return .none
                
            // 검색 결과 위치를 선택했을 때
            case .router(.routeAction(id: _, action: .search(.selectLocation(let result)))):
                // SearchLocationFeature 상태 초기화
                let locationState = SearchLocationFeature.State(
                    locationId: result.locationId,
                    locationTitle: result.title
                )
                
                // 새로운 화면으로 이동 (검색 화면은 유지)
                state.routes.push(.searchLocation(locationState))
                return .none
                
            // SearchLocation 화면에서 홈으로 돌아가기
            case .router(.routeAction(id: _, action: .searchLocation(.routeToHomeScreen))):
                // 모든 화면을 제거하고 루트 화면(map)만 남김
                state.routes = [.root(.map(.initialState), embedInNavigationView: true)]
                return .none
                
            // 검색 화면에서 뒤로 가기
            case .router(.routeAction(id: _, action: .search(.routeToPreviousScreen))):
                state.routes.goBack()
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
