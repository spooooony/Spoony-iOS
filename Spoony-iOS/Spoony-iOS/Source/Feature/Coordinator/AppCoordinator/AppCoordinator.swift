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
    case onboarding(OnboardingFeature)
    case tabRootCoordinator(TabRootCoordinator)
}

@Reducer
struct AppCoordinator {
    @ObservableState
    struct State: Equatable {
        static let initialState = State(routes: [.root(.auth(.initialState), embedInNavigationView: false)])
        
        var routes: [Route<AppScreen.State>]
        
        var toast: Toast?
    }
    
    enum Action {
        // MARK: - Navigation Action: 현재 Reducer에서 화면 전환 시 사용
        case router(IndexedRouterActionOf<AppScreen>)
        case routeToLoginScreen
        case updateToast(Toast?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: _, action: childDelegateAction)):
                switch childDelegateAction {
                case .auth(.delegate(let routeAction)):
                    switch routeAction {
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                        
                    case .routeToTabCoordinatorScreen:
                        state.routes = [.root(.tabRootCoordinator(.initialState), embedInNavigationView: false)]
                        return .none
                        
                    case .routeToTermsOfServiceScreen:
                        state.routes = [.root(.termsOfService(.initialState), embedInNavigationView: false)]
                        return .none
                    }
                    
                case .onboarding(.delegate(let routeAction)):
                    switch routeAction {
                    case .presentToast(let type):
                        state.toast = .init(message: type.message)
                        return .none
                        
                    case .routeToTabCoordinatorScreen:
                        state.routes = [.root(.tabRootCoordinator(.initialState), embedInNavigationView: false)]
                        return .none
                    }
                    
                case .tabRootCoordinator(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToLoginScreen:
                        state.routes = [.root(.auth(.initialState), embedInNavigationView: false)]
                        return .none
                    }
                    
                case .termsOfService(.delegate(let routeAction)):
                    switch routeAction {
                    case .routeToOnboardingScreen:
                        state.routes = [.root(.onboarding(.initialState), embedInNavigationView: false)]
                        return .none
                    }
                    
                default:
                    return .none
                }
                
                // toast
            case .updateToast(let toast):
                state.toast = toast
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
