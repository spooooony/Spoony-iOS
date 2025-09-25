//
//  PostUseCase.swift
//  Spoony-iOS
//
//  Created by 이명진 on 2/7/25.
//

// MARK: ** 레거시 추후 삭제 예정 **
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
    private let postRepository: PostServiceProtocol
    private let homeService: HomeServiceType
    
    // TDOO: HomeService 리팩토링 되면 코드 수정
    init(
        postRepository: PostServiceProtocol = DefaultPostService(),
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
            
            print("🔍 2. getPost 함수 실행")
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

struct MockPostUseCase: PostUseCase {
    
    func getPost(postId: Int) async throws -> PostModel {
        return MockData.postDetail
    }
    
    func scrapPost(postId: Int) async throws {
        print("스크랩")
    }
    
    func unScrapPost(postId: Int) async throws {
        print("스크랩 취소")
    }
    
    func scoopPost(postId: Int) async throws -> Bool {
        print("떠먹기 기능")
        return true
    }
    
    func getMyUserInfo() async throws -> UserInfoResponseDTO {
        return MockData.userInfo
    }
    
    func getOtherUserInfo(userId: Int) async throws -> UserInfoResponseDTO {
        return MockData.userInfo
    }
    
    func deletePost(postId: Int) async throws {
        return
    }
}

struct MockData {
    
    static let postResponse: PostResponseDTO = PostResponseDTO(
        postId: 20,
        userId: 30,
        photoUrlList: [
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/4e827dbf-a100-4dff-837e-ed4008e050421-1.jpeg",
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/e159e90c-7fc4-46cc-aab5-d82410208b7a1-2.jpeg",
            "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/post/e383b6fc-1d2e-4824-83ce-56e0c3620eb21-3.jpg"
        ],
        date: "2025-05-14T15:56:51.808876",
        menuList: ["메뉴1", "메뉴2"],
        description: "이자카야인데 친구랑 가서 안주만 5개 넘게 시킴.. 명성이 자자한 고등어봉 초밥은 꼭 시키세요! 입에 넣자마자 사르르 녹아 없어짐. 그리고 밤 후식 진짜 맛도리니까 밤 디저트 좋아하는 사람이면 꼭 먹어보기! ",
        value: 50,
        cons: "하하하하 null 값으로 와서 싫음",
        placeName: "테스트 장소",
        placeAddress: "서울 강남구 장소가 왜 길어지면 사지분리가 되는거야 김세은 : ㅅㅂ, 배가희: ㅅㅂ, 정다은: ㅅㅂ zzzz",
        latitude: 37.497946,
        longitude: 127.027632,
        zzimCount: 1,
        isZzim: true,
        isScoop: false,
        isMine: false,
        categoryColorResponse: DetailCategoryColorResponse(
            categoryId: 1,
            categoryName: "전체",
            iconUrl: nil,
            iconTextColor: nil,
            iconBackgroundColor: nil
        )
    )
    
    static let userInfo: UserInfoResponseDTO = UserInfoResponseDTO(
        userId: 30,
        platform: "APPLE",
        platformId: "test_id_30",
        userName: "이지훈",
        regionName: "강북구",
        introduction: "스푸니 짱짱",
        createdAt: "2025-03-01T12:34:56",
        updatedAt: "2025-03-01T12:34:56",
        followerCount: 100,
        followingCount: 50,
        isFollowing: false,
        reviewCount: 9,
        profileImageUrl: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/profile/image_avatar_hamburger.png"
    )
    
    static let spoonCount: Int = 5623
    
    // 최종적으로 사용될 Mock PostModel
    static let postDetail: PostModel = PostModel(
        postDto: postResponse,
        userInfo: userInfo,
        spoonCount: spoonCount
    )
}

