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

protocol LoginServiceProtocol {
    func kakaoLogin() async throws -> String
    func appleLogin() async throws -> String
}

final class DefaultLoginService: NSObject, LoginServiceProtocol {
    private var appleLoginContinuation: CheckedContinuation<String, Error>?

    func kakaoLogin() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let resultHandler: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let oauthToken = oauthToken {
                    let token = oauthToken.accessToken
                    #if DEBUG
                    print("kakao token: \(token)")
                    #endif
                    
                    continuation.resume(returning: token)
                }
            }
            Task { @MainActor in
                // 앱으로 로그인
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: resultHandler)
                } else {
                    // 웹으로 로그인
                    UserApi.shared.loginWithKakaoAccount(completion: resultHandler)
                }
            }
        }
    }
    
    func appleLogin() async throws -> String {
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

extension DefaultLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
           let token {
            continuation.resume(returning: token)
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
