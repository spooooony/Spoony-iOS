//
//  OnboardingRepository.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

struct OnboardingRepository: OnboardingInterface {
    private let authService: AuthServiceProtocol
    
    // MARK: - persistence
    private let authenticationManager = AuthenticationManager.shared
    private let userManager = UserManager.shared
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signup(info: SignUpEntity) async throws -> String {
        do {
            let platform = authenticationManager.socialType
            guard let socialToken = authenticationManager.socialToken
            else { throw SNError.etc }
            
            let request: SignupRequestDTO
            
            if let code = authenticationManager.appleCode {
                request = SignupRequestDTO.toDTO(from: info, platform: platform.rawValue, code: code)
            } else {
                request = SignupRequestDTO.toDTO(from: info, platform: platform.rawValue, code: nil)
            }
            
            let result = try await authService.signup(info: request, token: socialToken)
            
            userManager.userId = result.user.userId
            userManager.completeOnboarding()
            
            let name = result.user.userName
            let token = result.jwtTokenDto
            KeychainManager.saveKeychain(
                access: token.accessToken,
                refresh: token.refreshToken,
                platform: platform.rawValue
            )
            
            return name
        } catch {
            throw error
        }
    }
}

struct MockOnboardingRepository: OnboardingInterface {
    func signup(info: SignUpEntity) async throws -> String {
        "대안용"
    }
}
