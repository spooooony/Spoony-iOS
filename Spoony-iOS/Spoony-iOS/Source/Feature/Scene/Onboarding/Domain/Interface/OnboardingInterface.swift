//
//  OnboardingInterface.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

protocol OnboardingInterface {
    func checkNicknameDuplicate(nickname: String) async throws -> Bool
}
