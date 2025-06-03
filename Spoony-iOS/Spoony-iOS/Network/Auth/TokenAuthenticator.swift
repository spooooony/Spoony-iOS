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
    func apply(_ credential: TokenCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
    }
    
    // 2) api 요청 후 응답의 상태코드가 401이면 true를 리턴하며 refresh 프로세스 계속 진행
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: any Error) -> Bool {
        return response.statusCode == 401
    }
    
    // 3) 헤더의 token과 credential의 token을 비교
    // 같은 경우: token 만료 -> refresh()
    // 다른 경우: apply부터 다시 호출하여 최신 token으로 재시도
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: TokenCredential) -> Bool {
        let token = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == token
    }
    
    //4) refresh api 호출
    func refresh(
        _ credential: TokenCredential,
        for session: Alamofire.Session,
        completion: @escaping @Sendable (Result<TokenCredential, any Error>) -> Void
    ) {
        let refreshToken = credential.refreshToken
        
        Task {
            do {
                let tokenSet = try await refreshService.refresh(token: refreshToken)
                completion(.success(tokenSet))
            } catch {
                // TODO: 로그인 화면으로 이동
                completion(.failure(error))
            }
        }
    }
}
