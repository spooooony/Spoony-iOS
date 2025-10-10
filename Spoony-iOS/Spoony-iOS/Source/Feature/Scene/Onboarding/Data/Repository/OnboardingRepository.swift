//
//  OnboardingRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

struct OnboardingRepository: OnboardingInterface {
    // MARK: - service
    private let myPageProvider = Providers.myPageProvider
    private let authProvider = Providers.authProvider
    
    // MARK: - persistence
    private let authenticationManager = AuthenticationManager.shared
    private let userManager = UserManager.shared
    
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        do {
            let result = try await myPageProvider.request(.nicknameDuplicateCheck(query: nickname))
                .map(to: BaseResponse<Bool>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            return data
        } catch {
            throw error
        }
    }

    func signup(info: SignUpEntity) async throws -> String {
        do {
            let platform = authenticationManager.socialType
            guard let socialToken = authenticationManager.socialToken
            else { throw SNError.etc }
            
            let request: SignupRequest
            
            if let code = authenticationManager.appleCode {
                request = SignUpMapper.toDTO(from: info, platform: platform.rawValue, code: code)
            } else {
                request = SignUpMapper.toDTO(from: info, platform: platform.rawValue,code: nil)
            }
            
            let result = try await authProvider.request(.signup(request, token: socialToken))
                .map(to: BaseResponse<SignupResponse>.self)
            
            guard let data = result.data else {
                throw SNError.noData
            }
            
            userManager.userId = data.user.userId
            userManager.completeOnboarding()
            
            let user = data.user.userName
            let token = data.jwtTokenDto
            KeychainManager.saveKeychain(
                access: token.accessToken,
                refresh: token.refreshToken,
                platform: platform.rawValue
            )
            
            return user
        } catch {
            throw error
        }
    }
}

struct MockOnboardingRepository: OnboardingInterface {
    func checkNicknameDuplicate(nickname: String) async throws -> Bool {
        return true
    }
    
    func signup(info: SignUpEntity) async throws -> String {
        "대안용"
    }
}
