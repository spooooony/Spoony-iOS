//
//  DetailUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol DetailUseCaseProtocol {
    func fetchInitialDetail(userId: Int, postId: Int) async throws -> ReviewDetailModel
    func scrapReview(userId: Int, postId: Int)
    func unScrapReview(userId: Int, postId: Int)
    func scoopReview(userId: Int, postId: Int) async throws -> Bool
    func getUserInfo(userId: Int) async throws -> UserInfoResponseDTO
}

struct DefaultDetailUseCase {
    private let detailRepository: DetailRepositoryInterface
    private let homeService: HomeServiceType
    
    init(
        detailRepository: DetailRepositoryInterface = DefaultDetailRepository(),
        homeService: HomeServiceType = DefaultHomeService()
    ) {
        self.detailRepository = detailRepository
        self.homeService = homeService // 다른 팀원의 파일이기 때문에 service로 어쩔 수 없이 주입해서 사용
    }
}

extension DefaultDetailUseCase: DetailUseCaseProtocol {
    func fetchInitialDetail(userId: Int, postId: Int) async throws -> ReviewDetailModel {
        let spoonCount = try await homeService.fetchSpoonCount(userId: userId)
        let reviewDetail = try await detailRepository.fetchReviewDetail(userId: userId, postId: postId)
        let userInfo = try await detailRepository.fetchUserInfo(userId: userId)
        
        return .init(reviewDetail: reviewDetail,  userInfo: userInfo, spoonCount: spoonCount)
    }
    
    func scrapReview(userId: Int, postId: Int) {
        detailRepository.scrapReview(userId: userId, postId: postId)
    }
    
    func unScrapReview(userId: Int, postId: Int) {
        detailRepository.unScrapReview(userId: userId, postId: postId)
    }
    
    func scoopReview(userId: Int, postId: Int) async throws -> Bool {
        return try await detailRepository.scoopReview(userId: userId, postId: postId)
    }
    
    func getUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await detailRepository.fetchUserInfo(userId: userId)
    }
}
