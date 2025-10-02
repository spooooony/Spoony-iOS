//
//  RefreshUseCase.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Foundation

protocol RefreshUseCaseProtocol {
    func execute() async throws
}

struct DefaultRefreshUseCase: RefreshUseCaseProtocol {
    func execute() async throws {
        // repository에서 가져오기
    }
}

struct MockRefreshUseCase: RefreshUseCaseProtocol {
    func execute() async throws {
        print("mock refresh !")
    }
}
