//
//  OnboardingRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

struct OnboardingRepository: OnboardingInterface {
    private let provider = Providers.myPageProvider
    
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        do {
            let result = try await provider.request(.nicknameDuplicateCheck(query: nickname))
                .map(to: BaseResponse<Bool>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }
}

struct MockOnboardingRepository: OnboardingInterface {
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return true
    }
}
