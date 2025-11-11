//
//  LoginService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import AuthenticationServices
import Foundation

import KakaoSDKUser
import KakaoSDKAuth

protocol SocialLoginServiceProtocol {
    func kakaoLogin() async throws -> String
    func appleLogin() async throws -> (token: String, code: String)
}

actor Resumable {
    private var isResumed = false
    private let continuation: CheckedContinuation<String, Error>
    
    init(continuation: CheckedContinuation<String, any Error>) {
        self.continuation = continuation
    }
    
    func resume(throwing: Error) {
        guard !isResumed else { return }
        isResumed = true
        continuation.resume(throwing: throwing)
    }
    
    func resume(returning: String) {
        guard !isResumed else { return }
        isResumed = true
        continuation.resume(returning: returning)
    }
}

final class DefaultSocialLoginService: NSObject, SocialLoginServiceProtocol {
    private var appleLoginContinuation: CheckedContinuation<(token: String, code: String), Error>?
    
    func kakaoLogin() async throws -> String {
        try await kakaoLoginLogic()
    }
    
    private func kakaoLoginLogic() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let resumable = Resumable(continuation: continuation)
            let resultHandler: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                Task {
                    if let error = error {
                        await resumable.resume(throwing: error)
                    } else if let oauthToken = oauthToken {
                        let token = oauthToken.accessToken
                        await resumable.resume(returning: token)
                    }
                }
            }
            
            Task { @MainActor in
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk { token, error in
                        resultHandler(token, error)
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount { token, error in
                        resultHandler(token, error)
                    }
                }
            }
        }
    }
    
    func appleLogin() async throws -> (token: String, code: String) {
        return try await withCheckedThrowingContinuation { continuation in
            appleLoginContinuation = continuation
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

extension DefaultSocialLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    // apple 로그인 UI를 어느 뷰에 표시할지 지정
    @MainActor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            fatalError("No window found")
        }
        return window
    }
    
    // apple id 연동 성공 시
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        
        let code = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
        let token = String(data: appleIDCredential.identityToken!, encoding: .utf8)
        
        #if DEBUG
        print("token \(String(describing: token))")
        print("code \(String(describing: code))")
        
        #endif
        
        if let continuation = appleLoginContinuation,
           let token,
           let code {
            continuation.resume(returning: (token, code))
        } else {
            appleLoginContinuation?.resume(throwing: LoginError.appleTokenError)
        }
    }
    
    // apple id 연동 실패 시
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let continuation = appleLoginContinuation {
            continuation.resume(throwing: error)
        }
    }
}
