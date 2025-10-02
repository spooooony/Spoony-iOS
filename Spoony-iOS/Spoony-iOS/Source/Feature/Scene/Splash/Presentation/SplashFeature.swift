//
//  SplashFeature.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

import ComposableArchitecture
import Mixpanel

@Reducer
struct SplashFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
    }
    
    enum Action {
        case viewAction(ViewAction)
        case privateAction(PrivateAction)
        case delegate(Delegate)
    }
    
    // MARK: - View에서 받은 Action
    enum ViewAction {
        case onAppear
    }
    
    // MARK: - Private Action
    enum PrivateAction {
        case refresh
        case refreshResult(TaskResult<Void>)
    }
    
    // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
    enum Delegate: Equatable {
        case routeToLogin
        case routeToHome
    }
    
    @Dependency(\.checkAutoLoginUseCase) var checkAutoLoginUseCase: CheckAutoLoginUseCaseProtocol
    @Dependency(\.refreshUseCase) var refreshUseCase: RefreshUseCaseProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAction(.onAppear):
                return .run { send in
                    let isAutoLogined = checkAutoLoginUseCase.execute()
                    if isAutoLogined {
                        await send(.privateAction(.refresh))
                    } else {
                        await send(.delegate(.routeToLogin))
                    }
                }
                
            case .privateAction(.refresh):
                return .run { send in
                    let result = await TaskResult {
                        try await refreshUseCase.execute()
                    }
                    await send(.privateAction(.refreshResult(result)))
                }
            case .privateAction(.refreshResult(.success)):
                Mixpanel.mainInstance().track(
                    event: ConversionAnalysisEvents.Name.loginsuccess
                )
                if let userId = UserManager.shared.userId {
                    Mixpanel.mainInstance().identify(distinctId: "\(userId)")
                }
                return .send(.delegate(.routeToHome))
            case .privateAction(.refreshResult(.failure)):
                return .send(.delegate(.routeToLogin))
                
            default: return .none
            }
        }
    }
}
