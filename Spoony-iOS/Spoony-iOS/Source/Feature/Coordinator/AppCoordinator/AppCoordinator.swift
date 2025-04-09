//
//  AppCoordinator.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/1/25.
//

import Foundation

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
enum AppScreen {
    case auth(LoginFeature)
    case termsOfService(AgreeFeature)
    case onboarding(Onboarding)
    case tabCoordinator(TabCoordinator)
}

@Reducer
struct AppCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.auth(.initialState), embedInNavigationView: false)])
        
        var routes: [Route<AppScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<AppScreen>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .auth(.routToTermsOfServiceScreen))):
                state.routes = [.root(.termsOfService(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .auth(.routToOnboardingScreen))):
                state.routes = [.root(.onboarding(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .auth(.routToTabCoordinatorScreen))):
                state.routes = [.root(.tabCoordinator(.initialState), embedInNavigationView: true)]
                return .none
                
            case .router(.routeAction(id: _, action: .termsOfService(.routToOnboardingScreen))):
                state.routes = [.root(.onboarding(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .termsOfService(.routToTabCoordinatorScreen))):
                state.routes = [.root(.tabCoordinator(.initialState), embedInNavigationView: true)]
                return .none
                
            case .router(.routeAction(id: _, action: .onboarding(.routToTabCoordinatorScreen))):
                state.routes = [.root(.tabCoordinator(.initialState), embedInNavigationView: true)]
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
