//
//  TokenAuthenticator.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/30/25.
//

import Foundation

import Alamofire

fileprivate actor RefreshActor {
    // actor는 한 번에 하나의 접근만 일어나서 동시에 여러 스레드에서 해당 변수에 접근해도 data race 발생 X
    private var currentTask: Task<TokenCredential, Error>?
    
    func refresh(refreshToken: String, service: RefreshProtocol) async throws -> TokenCredential {
        let currentRefreshToken = TokenManager.shared.currentRefreshToken ?? ""
        
        // 이미 refresh 됨
        if refreshToken != currentRefreshToken {
            return TokenCredential(
                accessToken: TokenManager.shared.currentToken ?? "",
                refreshToken: currentRefreshToken
            )
        }
        
        // 이미 진행 중인 refresh task가 있으면 해당 task의 결과를 return
        // refresh가 한 번만 호출되도록 보장
        if let currentTask {
            return try await currentTask.value
        }
        
        // refresh하는 Task를 생성
        let newTask = Task { () throws -> TokenCredential in
            defer { currentTask = nil }
            do {
                let tokenSet = try await service.refresh(token: refreshToken)
                
                _ = KeychainManager.create(key: .accessToken, value: tokenSet.accessToken)
                _ = KeychainManager.create(key: .refreshToken, value: tokenSet.refreshToken)
                return tokenSet
            } catch {
                _ = KeychainManager.delete(key: .accessToken)
                _ = KeychainManager.delete(key: .refreshToken)
                _ = KeychainManager.delete(key: .socialType)
                
                await MainActor.run {
                    NotificationCenter.default.post(name: .loginNotification, object: nil)
                }
                
                throw error
            }
        }
        currentTask = newTask
        return try await newTask.value
    }
}

final class TokenAuthenticator: Authenticator {
    private let refreshService: RefreshProtocol
    private let refreshManager = RefreshActor()
    
    init(refreshService: RefreshProtocol) {
        self.refreshService = refreshService
    }
    
    // 1) 요청하기 전 호출되어 헤더에 JWT 토큰 추가
    func apply(_ credential: TokenCredential, to urlRequest: inout URLRequest) {
        urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
        
#if DEBUG
        print("🔑 API 요청 시 사용되는 토큰: \(credential.accessToken.prefix(30))...")
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
        let headerToken = HTTPHeader.authorization(bearerToken: credential.accessToken).value
        return urlRequest.headers["Authorization"] == headerToken
    }
    
    //4) refresh api 호출
    func refresh(
        _ credential: TokenCredential,
        for session: Alamofire.Session,
        completion: @escaping @Sendable (Result<TokenCredential, any Error>) -> Void
    ) {
        Task {
            do {
                let result = try await refreshManager.refresh(refreshToken: credential.refreshToken, service: refreshService)
                
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
