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
        case router(IndexedRouterActionOf<AppScreen>)
        case routeToLoginScreen
        case updateToast(Toast?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .auth(.routToTermsOfServiceScreen))):
                state.routes = [.root(.termsOfService(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .auth(.routToTabCoordinatorScreen))):
                state.routes = [.root(.tabRootCoordinator(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .termsOfService(.routToOnboardingScreen))):
                state.routes = [.root(.onboarding(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .onboarding(.routToTabCoordinatorScreen))):
                state.routes = [.root(.tabRootCoordinator(.initialState), embedInNavigationView: false)]
                return .none
                
            case .router(.routeAction(id: _, action: .tabRootCoordinator(.routeToLogin))):
                print("🔄 AppCoordinator: TabRootCoordinator에서 routeToLogin 받음")
                return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
                    print("🔄 AppCoordinator: 로그인 화면으로 라우팅 실행")
                    $0 = [.root(.auth(.initialState), embedInNavigationView: false)]
                }
                
            case .routeToLoginScreen:
                state.routes = [.root(.auth(.initialState), embedInNavigationView: false)]
                return .none
                
            // toast
            case .updateToast(let toast):
                state.toast = toast
                return .none
                
            case .router(.routeAction(id: _, action: .auth(.presentToast(message: let message)))):
                state.toast = .init(style: .gray, message: message, yOffset: 665.adjustedH)
                return .none
                
            case .router(.routeAction(id: _, action: .onboarding(.presentToast(message: let message)))):
                state.toast = .init(style: .gray, message: message, yOffset: 665.adjustedH)
                return .none
                
            default:
                return .none
            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
