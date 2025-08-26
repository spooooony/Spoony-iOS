//
//  TokenAuthenticator.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/30/25.
//

import Foundation

import Alamofire

final class TokenAuthenticator: Authenticator {
    private let refreshService: RefreshProtocol
    
    init(refreshService: RefreshProtocol) {
        self.refreshService = refreshService
    }

    // 1) 요청하기 전 호출되어 헤더에 JWT 토큰 추가
    // credential 무시하고 매번 최신 토큰 사용
    func apply(_ credential: TokenCredential, to urlRequest: inout URLRequest) {
        let currentToken = TokenManager.shared.currentToken ?? ""
        urlRequest.headers.add(.authorization(bearerToken: currentToken))
        
        #if DEBUG
        print("🔑 API 요청 시 사용되는 토큰: \(currentToken.prefix(30))...")
        #endif
    }
    
    // 2) api 요청 후 응답의 상태코드가 401이면 true를 리턴하며 refresh 프로세스 계속 진행
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error) -> Bool {
        return response.statusCode == 401
    }
    
    // 3) 헤더의 token과 credential의 token을 비교
    // 현재 토큰과 비교하도록 수정
    // 같은 경우: token 만료 -> refresh()
    // 다른 경우: apply부터 다시 호출하여 최신 token으로 재시도
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: TokenCredential) -> Bool {
        let currentToken = TokenManager.shared.currentToken ?? ""
        let headerToken = HTTPHeader.authorization(bearerToken: currentToken).value
        return urlRequest.headers["Authorization"] == headerToken
    }
    
    //4) refresh api 호출
    func refresh(
        _ credential: TokenCredential,
        for session: Alamofire.Session,
        completion: @escaping @Sendable (Result<TokenCredential, any Error>) -> Void
    ) {
        let refreshToken = TokenManager.shared.currentRefreshToken ?? ""
        
        Task {
            do {
                let tokenSet = try await refreshService.refresh(token: refreshToken)
                
                _ = KeychainManager.create(key: .accessToken, value: tokenSet.accessToken)
                _ = KeychainManager.create(key: .refreshToken, value: tokenSet.refreshToken)
                
                completion(.success(tokenSet))
            } catch {
                await MainActor.run {
                    _ = KeychainManager.delete(key: .accessToken)
                    _ = KeychainManager.delete(key: .refreshToken)
                    _ = KeychainManager.delete(key: .socialType)
                    NotificationCenter.default.post(name: .loginNotification, object: nil)
                }
                completion(.failure(error))
            }
        }
    }
}
