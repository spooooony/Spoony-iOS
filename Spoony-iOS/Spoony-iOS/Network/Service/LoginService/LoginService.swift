//
//  LoginService.swift
//  Spoony-iOS
//
//  Created by 최주리 on 3/12/25.
//

import Foundation

import KakaoSDKUser

protocol LoginServiceProtocol {
    func kakaoLogin()
    func appleLogin()
}

final class DefaultLoginService: LoginServiceProtocol {
    func kakaoLogin() {
        // 카카오톡 실행 가능 여부 확인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    // 성공 시 동작 구현
                    _ = oauthToken
                    print(oauthToken?.accessToken)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    // 성공 시 동작 구현
                    _ = oauthToken
                    print(oauthToken?.accessToken)
                }
            }
        }
    }
    
    func appleLogin() {
        print("apple login")
    }
}
