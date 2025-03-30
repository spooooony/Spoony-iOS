//
//  AgreeFeature.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/30/25.
//

import Foundation

import ComposableArchitecture

@Reducer
struct AgreeFeature {
    
    @ObservableState
    struct State {
        var allCheckboxFilled: Bool = false
        var isDisableButton: Bool = true
        var selectedAgrees: [AgreeType] = []
    }
    
    enum Action: BindableAction {
    case binding(BindingAction<State>)
    case allAgreeTapped
    case agreeURLTapped(AgreeType)
    case selectedAgreeTapped(AgreeType)
    case unSelectedAgreeTapped(AgreeType)
    case selectedAgreesChanged([AgreeType])
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .allAgreeTapped:
                if state.allCheckboxFilled {
                    state.selectedAgrees = []
                } else {
                    state.selectedAgrees = AgreeType.allCases
                }
                return .none
            case .agreeURLTapped(let agree):
                // url 연결하기
                guard let url = agree.url else { return .none }
                print(url)
                return .none
            case .selectedAgreeTapped(let agree):
                let index = state.selectedAgrees.firstIndex(of: agree)!
                state.selectedAgrees.remove(at: index)
                return .none
            case .unSelectedAgreeTapped(let agree):
                state.selectedAgrees.append(agree)
                return .none
            case .selectedAgreesChanged(let agrees):
                state.allCheckboxFilled = agrees.count == AgreeType.allCases.count
                state.isDisableButton = !state.allCheckboxFilled
                return .none
            case .binding:
                return .none
            }
            
        }
    }
    
}
