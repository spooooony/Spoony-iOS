//
//  LoginService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import KakaoSDKUser
import KakaoSDKAuth

protocol LoginServiceProtocol {
    func kakaoLogin() async throws -> String
    func appleLogin()
}

final class DefaultLoginService: LoginServiceProtocol {

    func kakaoLogin() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let resultHandler: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let oauthToken = oauthToken,
                    let token = oauthToken.idToken {
                    continuation.resume(returning: token)
                }
            }
            
            // 앱으로 로그인
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: resultHandler)
            } else {
                // 웹으로 로그인
                UserApi.shared.loginWithKakaoAccount(completion: resultHandler)
            }
        }
    }
    
    func appleLogin() {
        print("apple login")
    }
}
