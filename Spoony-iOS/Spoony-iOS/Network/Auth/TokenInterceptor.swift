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
    
    func addPendingRequest(_ request: PendingRequest) -> Task<TokenCredential, Error>? {
        pendingRequests.append(request)
        return refreshTask
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
    
    func setTaskIfNeeded(currentRefreshToken: String, task: Task<TokenCredential, Error>?) -> Bool {
        if refreshTask != nil { return false }
        
        if let last = latestRefreshToken, last != currentRefreshToken {
            return false
        }
        
        latestRefreshToken = currentRefreshToken
        refreshTask = task
        return true
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
            
#if DEBUG
            print("🔑 API 요청에 토큰 추가: \(accessToken.prefix(30))...")
#endif
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse else {
            completion(.doNotRetry)
            return
        }
        
        // 401 Unauthorized가 아니면 재시도하지 않음
        guard response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        #if DEBUG
        print("🔄 401 응답 받음, 토큰 갱신 시도: \(request.request?.url?.absoluteString ?? "missing url")")
        #endif
        
        handleTokenRefresh(for: request, completion: completion)
    }
    
}

extension TokenInterceptor {
    private func handleTokenRefresh(
        for request: Request,
        completion: @escaping (RetryResult) -> Void
    ) {
        let pendingRequest = PendingRequest(request: request, completion: completion)
        Task {
            // Actor에서 request 저장하면서 현재 진행 중인 작업이 있는지 받아옴
            let existingTask = await refreshActor.addPendingRequest(pendingRequest)
            
            // 이미 진행 중인 작업이 있으면 기다림
            if let task = existingTask {
                do {
                    _ = try await task.value
                } catch {
                    completion(.doNotRetry)
                }
                return
            }
            
            // 새로운 refresh 작업 시작
            await startTokenRefresh()
        }
    }
    
    private func startTokenRefresh() async {
        guard let refreshToken = TokenManager.shared.currentRefreshToken else {
            await refreshActor.completePendingRequests(with: .doNotRetry)
            return
        }
        
        let refreshTask = Task<TokenCredential, Error> {
            try await refreshService.refresh(token: refreshToken)
        }
        
        let shouldStart = await refreshActor.setTaskIfNeeded(currentRefreshToken: refreshToken, task: refreshTask)
        
        if !shouldStart {
            await refreshActor.completePendingRequests(with: .retry)
            return
        }
        
        do {
            print("🔄 토큰 갱신 요청 !!")
            let newTokenSet = try await refreshTask.value
            
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
