//
//  OnboardingInterface.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

protocol OnboardingInterface {
    func signup(info: SignUpEntity) async throws -> String
}
