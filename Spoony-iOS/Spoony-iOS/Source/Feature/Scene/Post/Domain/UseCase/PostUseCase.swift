//
//  PostUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

protocol PostUseCase {
    func getPost(postId: Int) async throws -> PostModel
    func scrapPost(postId: Int) async throws
    func unScrapPost(postId: Int) async throws
    func scoopPost(postId: Int) async throws -> Bool
    func getMyUserInfo() async throws -> UserInfoResponseDTO
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO
    func deletePost(postId: Int) async throws
}

struct PostUseCaseImpl {
    private let postRepository: PostRepositoryInterface
    private let homeService: HomeServiceType
    
    // TDOO: HomeService 리팩토링 되면 코드 수정
    init(
        postRepository: PostRepositoryInterface = DefaultPostRepository(),
        homeService: HomeServiceType = DefaultHomeService()
    ) {
        self.postRepository = postRepository
        self.homeService = homeService // 다른 팀원의 파일이기 때문에 service로 어쩔 수 없이 주입해서 사용
    }
}

extension PostUseCaseImpl: PostUseCase {
    
    func getPost(postId: Int) async throws -> PostModel {
        do {
            print("🔍 1. get spoonCount")
            let spoonCount = try await homeService.fetchSpoonCount()
            print("✅ 1. spoonCount =", spoonCount)
            
            print("🔍 2. get reviewDetail")
            let postData = try await postRepository.getPost(postId: postId)
            print("✅ 2. postData = \(postData)")
            
            print("🔍 3. get userInfo")
            let userInfo = try await postRepository.getOtherUserInfo(userId: postData.userId)
            print("✅ 3. userInfo =", userInfo.userName)
            
            return PostModel(postDto: postData, userInfo: userInfo, spoonCount: spoonCount)
        } catch {
            print("❌ getPost error:", error)
            throw error
        }
    }
    
    func scrapPost(postId: Int) async throws {
        try await postRepository.scrapPost(postId: postId)
    }
    
    func unScrapPost(postId: Int) async throws {
        try await postRepository.unScrapPost(postId: postId)
    }
    
    func scoopPost(postId: Int) async throws -> Bool {
        return try await postRepository.scoopPost(postId: postId)
    }
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return try await postRepository.getMyUserInfo()
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return try await postRepository.getOtherUserInfo(userId: userId)
    }
    
    func deletePost(postId: Int) async throws {
        try await postRepository.deletePost(postId: postId)
    }
    
}
