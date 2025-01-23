//
//  DetailService.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

public class DetailService {
    
    let detailProvider = Providers.detailProvider
    
    func getReviewDetail(userId: Int, postId: Int, completion: @escaping (Result<ReviewDetailModel, SNError>) -> Void) {
        detailProvider.request(.getDetailReview(userId: 1, postId: postId)) { result in
            switch result {
            case .success(let response):
                do {
                    let responseDto = try response.map(BaseResponse<ReviewDetailModel>.self)
                    
                    if let data = responseDto.data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.decodeError))
                    }
                    
                } catch {
                    print("decode map to error")
                }
            case .failure(let error):
                print("통신 실패: \(error)")
            }
        }
    }
    
    func scrapReview(userId: Int, postId: Int) {
        detailProvider.request(.scrapReview(userId: 30, postId: postId)) { result in
            switch result {
            case .success(let response):
                do {
                    _ = try response.map(BaseResponse<BlankData>.self)
                    
                } catch {
                    print("decode map to error")
                }
            case .failure(let error):
                print("통신 실패: \(error)")
            }
        }
    }
    
    func unScrapReview(userId: Int, postId: Int) {
        detailProvider.request(.unScrapReview(userId: 30, postId: postId)) { result in
            switch result {
            case .success(let response):
                do {
                    _ = try response.map(BaseResponse<BlankData>.self)
                    
                } catch {
                    print("decode map to error")
                }
            case .failure(let error):
                print("통신 실패: \(error)")
            }
        }
    }
    
    func scoopReview(userId: Int, postId: Int) async throws -> Bool {
        
        return try await withCheckedThrowingContinuation { continuation in
            detailProvider.request(.scoopReview(userId: Config.userId, postId: postId)) { result in
                switch result {
                case .success(let response):
                    do {
                        _ = try response.map(BaseResponse<BlankData>.self)
                        return continuation.resume(returning: true)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
