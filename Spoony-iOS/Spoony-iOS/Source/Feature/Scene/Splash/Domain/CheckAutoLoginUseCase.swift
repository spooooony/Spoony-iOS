//
//  CheckAutoLoginUseCase.swift
//  Spoony
//
//  Created by 최주리 on 9/30/25.
//

protocol CheckAutoLoginUseCaseProtocol {
    func execute() -> Bool
}

struct DefualtCheckAutoLoginUseCase: CheckAutoLoginUseCaseProtocol {
    func execute() -> Bool {
        // repository에서 가져오기
        return true
    }
}

struct MockCheckAutoLoginUseCase: CheckAutoLoginUseCaseProtocol {
    func execute() -> Bool {
        return true
    }
}
