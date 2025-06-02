//
//  DetailUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol DetailUseCase {
    func fetchInitialDetail(postId: Int) async throws -> ReviewDetailModel
    func scrapReview(postId: Int) async throws
    func unScrapReview(postId: Int) async throws
    func scoopReview(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deleteReview(postId: Int) async throws
}

struct DetailUseCaseImpl {
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

extension DetailUseCaseImpl: DetailUseCase {
    
    func fetchInitialDetail(postId: Int) async throws -> ReviewDetailModel {
        do {
            print("🔍 1. get spoonCount")
            let spoonCount = try await homeService.fetchSpoonCount()
            print("✅ 1. spoonCount =", spoonCount)

            print("🔍 2. get reviewDetail")
            let reviewDetail = try await detailRepository.fetchReviewDetail(postId: postId)
            print("✅ 2. reviewDetail = \(reviewDetail)")

            print("🔍 3. get userInfo")
            let userInfo = try await detailRepository.getOtherUserInfo(userId: reviewDetail.userId)
            print("✅ 3. userInfo =", userInfo.userName)

            return ReviewDetailModel(reviewDetail: reviewDetail, userInfo: userInfo, spoonCount: spoonCount)
        } catch {
            print("❌ fetchInitialDetail error:", error)
            throw error
        }
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
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return try await detailRepository.getMyUserInfo()
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await detailRepository.getOtherUserInfo(userId: userId)
    }
    
    func deleteReview(postId: Int) async throws {
        try await detailRepository.deleteReview(postId: postId)
    }

}
