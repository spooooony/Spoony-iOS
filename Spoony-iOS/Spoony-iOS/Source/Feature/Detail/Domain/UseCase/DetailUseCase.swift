//
//  DetailUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol DetailUseCaseProtocol {
    func fetchInitialDetail(postId: Int) async throws -> ReviewDetailModel
    func scrapReview(postId: Int) async throws
    func unScrapReview(postId: Int) async throws
    func scoopReview(postId: Int) async throws -> Bool
    func getUserInfo() async throws -> UserInfoResponseDTO
}

struct DefaultDetailUseCase {
    private let detailRepository: DetailRepositoryInterface
    private let homeService: HomeServiceType
    
    // TDOO: HomeService 리팩토링 되면 코드 수정
    init(
        detailRepository: DetailRepositoryInterface = DefaultDetailRepository(),
        homeService: HomeServiceType = DefaultHomeService()
    ) {
        self.detailRepository = detailRepository
        self.homeService = homeService // 다른 팀원의 파일이기 때문에 service로 어쩔 수 없이 주입해서 사용
    }
}

extension DefaultDetailUseCase: DetailUseCaseProtocol {
    
    func fetchInitialDetail(postId: Int) async throws -> ReviewDetailModel {
        let spoonCount = try await homeService.fetchSpoonCount()
        let reviewDetail = try await detailRepository.fetchReviewDetail(postId: postId)
        let userInfo = try await detailRepository.fetchUserInfo()
        
        return ReviewDetailModel(reviewDetail: reviewDetail, userInfo: userInfo, spoonCount: spoonCount)
    }
    
    func scrapReview(postId: Int) async throws {
        try await detailRepository.scrapReview(postId: postId)
    }
    
    func unScrapReview(postId: Int) async throws {
        try await detailRepository.unScrapReview(postId: postId)
    }
    
    func scoopReview(postId: Int) async throws -> Bool {
        return try await detailRepository.scoopReview(postId: postId)
    }
    
    func getUserInfo() async throws -> UserInfoResponseDTO {
        return try await detailRepository.fetchUserInfo()
    }
}
