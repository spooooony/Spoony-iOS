//
//  TokenInterceptor.swift
//  Spoony
//
//  Created by 최주리 on 9/7/25.
//

import Foundation

import Alamofire

struct PendingRequest {
    let request: Request
    let completion: (RetryResult) -> Void
}

actor RefreshActor {
    private var refreshTask: Task<TokenCredential, Error>?
    private var pendingRequests: [PendingRequest] = []
    private var latestRefreshToken: String?
    
    static let shared = RefreshActor()
    
    private init() { }
    
    func addRequestAndStartRefresh(
        request: PendingRequest,
        refreshToken: String,
        inputTask: () -> Task<TokenCredential, Error>
    ) -> (Task<TokenCredential, Error>, Bool) {
        pendingRequests.append(request)
        
        if let task = refreshTask {
            return (task, false)
        }
        
        if let last = latestRefreshToken, last != refreshToken {
            return (refreshTask!, false)
        }
        
        latestRefreshToken = refreshToken
        let task = inputTask()
        refreshTask = task
        return (task, true)
    }

    func completePendingRequests(with result: RetryResult) {
        for pendingRequest in pendingRequests {
            pendingRequest.completion(result)
        }
        
        pendingRequests.removeAll()
        refreshTask = nil
        latestRefreshToken = nil
    }
    
    func getPendingRequestCount() -> Int {
        return pendingRequests.count
    }
}

final class TokenInterceptor: RequestInterceptor {
    private let refreshService: RefreshProtocol
    private let refreshActor = RefreshActor.shared
    
    init(refreshService: RefreshProtocol) {
        self.refreshService = refreshService
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        
        var urlRequest = urlRequest
        
        if let accessToken = TokenManager.shared.currentToken {
            urlRequest.headers.add(.authorization(bearerToken: accessToken))
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        guard response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        #if DEBUG
        print("🔄 401 응답 받음: \(request.request?.url?.absoluteString ?? "missing url")")
        #endif
        
        handleTokenRefresh(for: request, completion: completion)
    }
    
}

extension TokenInterceptor {
    private func handleTokenRefresh(
        for request: Request,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let refreshToken = TokenManager.shared.currentRefreshToken else {
            completion(.doNotRetry)
            return
        }
        
        let pendingRequest = PendingRequest(request: request, completion: completion)
        
        Task {
            let (task, isNew) = await refreshActor.addRequestAndStartRefresh(
                request: pendingRequest,
                refreshToken: refreshToken
            ) {
                Task {
                    try await refreshService.refresh(token: refreshToken)
                }
            }
            
            // 새로운 refresh 작업 시작
            if isNew {
                await startTokenRefresh(task: task)
            }
        }
    }
    
    private func startTokenRefresh(task: Task<TokenCredential, Error>) async {
        do {
            let newTokenSet = try await task.value
            
            // 성공 처리
            TokenManager.shared.updateTokens(
                accessToken: newTokenSet.accessToken,
                refreshToken: newTokenSet.refreshToken
            )
        
            #if DEBUG
            let count = await refreshActor.getPendingRequestCount()
            print("🔄 토큰 갱신 성공, 대기 중인 \(count)개 요청 재시도")
            #endif
            
            await refreshActor.completePendingRequests(with: .retry)
            
        } catch {
            
            #if DEBUG
            print("❌ 토큰 갱신 실패: \(error)")
            #endif
            
            TokenManager.shared.deleteTokens()
            await MainActor.run {
                NotificationCenter.default.post(name: .loginNotification, object: nil)
            }
            await refreshActor.completePendingRequests(with: .doNotRetry)
        }
    }
}
