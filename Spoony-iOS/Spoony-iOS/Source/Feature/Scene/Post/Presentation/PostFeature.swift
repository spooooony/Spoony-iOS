//
//  PostFeature.swift
//  Spoony-iOS
//
//  Created by 이명진 on 3/4/25.
//

import ComposableArchitecture
import Mixpanel

enum PostError: Error {
    case noData
    case zzimError
    case spoonError
    case userError
    
    var description: String {
        switch self {
        case .noData:
            return "네트워크 요청에 실패했습니다."
        case .zzimError:
            return "스크랩에 실패했습니다."
        case .spoonError:
            return "떠먹기에 실패 했습니다."
        case .userError:
            return "해당 유저를 불러올 수 없습니다."
        }
    }
}

@Reducer
struct PostFeature {
    @ObservableState
    struct State: Equatable {
        var isZzim: Bool = false
        var isScoop: Bool = false
        var spoonCount: Int = 0
        var zzimCount: Int = 0
        var isLoading: Bool = false
        var successService: Bool = true
        var showAttendanceView: Bool = false
        
        var userId: Int = 0
        var postId: Int = 0
        var userName: String = ""
        var photoUrlList: [String] = []
        var date: String = "2025-08-21"
        var menuList: [String] = []
        var description: String = ""
        var placeName: String = ""
        var placeAddress: String = ""
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        var categoryName: String = ""
        var iconUrl: String = ""
        var iconTextColor: String = ""
        var iconBackgroundColor: String = ""
        var categoryColorResponse: DetailCategoryColorResponse = .init(categoryId: 0, categoryName: "", iconUrl: "", iconTextColor: "", iconBackgroundColor: "")
        var isMine: Bool = true
        var profileImageUrl: String = ""
        var regionName: String = ""
        var value: Double = 0.0
        var cons: String = ""
        var isFollowing: Bool = false
        
        var isUseSpoonPopupVisible: Bool = false
        var isDeletePopupVisible: Bool = false
        
        var showDailySpoonPopup: Bool = false
        var isDrawingSpoon: Bool = false
        var drawnSpoon: SpoonDrawResponse?
        var spoonDrawError: String?
    }
    
    enum Action {
        case viewAppear(postId: Int)
        case fetchInitialResponse(Result<PostModel, PostError>)
        
        case scoopButtonTapped
        case scoopButtonTappedResponse(isSuccess: Bool)
        
        case zzimButtonTapped(isZzim: Bool)
        case zzimButtonResponse(isScrap: Bool)
        
        case followButtonTapped(userId: Int, isFollowing: Bool)
        case followActionResponse(Result<Void, Error>)
        
        case editButtonTapped
        
        case mixpanelEvent
        
        case showUseSpoonPopup
        case confirmUseSpoonPopup
        case dismissUseSpoonPopup
        
        case showDeletePopup
        case confirmDeletePopup
        case dismissDeletePopup
        
        case spoonTapped
        
        case setShowDailySpoonPopup(Bool)
        case drawDailySpoon
        case spoonDrawResponse(TaskResult<SpoonDrawResponse>)
        case fetchSpoonCount
        case spoonCountResponse(TaskResult<Int>)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate {
            case routeToPreviousScreen
            case routeToReportScreen(Int)
            case routeToEditReviewScreen(Int)
            case routeToUserProfileScreen(Int)
            case routeToMyProfileScreen
            case routeToAttendanceView
            case presentToast(ToastType)
        }
    }
    
    @Dependency(\.postUseCase) var postUseCase: PostUseCase
    @Dependency(\.followUseCase) var followUseCase: FollowUseCase
    @Dependency(\.homeService) var homeService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewAppear(let postId):
                state.isLoading = true
                
                return .run { [postId] send in
                    do {
                        let data = try await postUseCase.getPost(postId: postId)
                        await send(.fetchInitialResponse(.success(data)))
                    } catch {
                        await send(.fetchInitialResponse(.failure(.userError)))
                    }
                }
                
            case .fetchInitialResponse(let result):
                state.isLoading = false
                switch result {
                case .success(let data):
                    state.successService = true
                    updateState(&state, with: data)
                case .failure(let error):
                    state.successService = false
                    return .send(.delegate(.presentToast(.serverError)))
                }
                return .none
                
            case .scoopButtonTapped:
                let property = makeReviewProperty(&state)
                Mixpanel.mainInstance().track(
                    event: ReviewEvents.Name.spoonUseIntent,
                    properties: property.dictionary
                )
                return .run { [postId = state.postId] send in
                    do {
                        let data = try await postUseCase.scoopPost(postId: postId)
                        await send(.scoopButtonTappedResponse(isSuccess: data))
                    } catch {
                        await send(.delegate(.presentToast(.spoonError)))
                    }
                }
                
            case .zzimButtonTapped(let isZzim):
                return .run { [postId = state.postId, isZzim] send in
                    do {
                        if isZzim {
                            try await postUseCase.unScrapPost(postId: postId)
                            await send(.zzimButtonResponse(isScrap: false))
                        } else {
                            try await postUseCase.scrapPost(postId: postId)
                            await send(.zzimButtonResponse(isScrap: true))
                        }
                    } catch {
                        await send(.delegate(.presentToast(.zzimError)))
                    }
                }
                
            case .zzimButtonResponse(let isScrap):
                if isScrap {
                    state.zzimCount += 1
                    state.isZzim.toggle()
                    let property = makeReviewProperty(&state)
                    Mixpanel.mainInstance().track(
                        event: ReviewEvents.Name.placeMapSaved,
                        properties: property.dictionary
                    )
                    return .send(.delegate(.presentToast(.savedToMap)))
                } else {
                    state.zzimCount -= 1
                    state.isZzim.toggle()
                    let property = makeReviewProperty(&state)
                    Mixpanel.mainInstance().track(
                        event: ReviewEvents.Name.placeMapRemoved,
                        properties: property.dictionary
                    )
                    return .send(.delegate(.presentToast(.deletedFromMap)))
                }
                
            case .followButtonTapped(let userId, let isFollowing):
                return .run { send in
                    do {
                        try await followUseCase.toggleFollow(userId: userId, isFollowing: isFollowing)
                        await send(.followActionResponse(.success(())))
                    } catch {
                        await send(.followActionResponse(.failure(error)))
                    }
                }
                
            case .followActionResponse(let result):
                switch result {
                case .success:
                    let property = CommonEvents.ReviewUserFollowInteractionProperty(
                        reviewId: state.postId,
                        authorUserId: state.userId,
                        placeId: 1,
                        placeName: state.placeName,
                        category: state.categoryName,
                        menuCount: state.menuList.count,
                        satisfaction: state.value,
                        reviewLength: state.description.count,
                        photoCount: state.photoUrlList.count,
                        hasDisappointment: !state.cons.isEmpty,
                        savedCount: state.zzimCount,
                        entryPoint: .explore
                    )
                    
                    if state.isFollowing {
                        Mixpanel.mainInstance().track(
                            event: CommonEvents.Name.unfollowUserFromReview,
                            properties: property.dictionary
                        )
                    } else {
                        Mixpanel.mainInstance().track(
                            event: CommonEvents.Name.followUserFromReview,
                            properties: property.dictionary
                        )
                    }
                    
                    state.isFollowing.toggle() // ✅ follow 상태 변경
                    return .none
                case .failure(let error):
                    print("❌ 팔로우 로직 실패 : \(error.localizedDescription)")
                    return .none
                }
                
            case .scoopButtonTappedResponse(let isSuccess):
                if isSuccess {
                    state.isScoop = true
                    state.spoonCount = max(0, state.spoonCount - 1)
                    return .none
                } else {
                    return .send(.delegate(.presentToast(.noSpoon)))
                }

            case .editButtonTapped:
                return .send(.delegate(.routeToEditReviewScreen(state.postId)))
        
            case .mixpanelEvent:
                let property = makeReviewProperty(&state)
                
                Mixpanel.mainInstance().track(
                    event: ReviewEvents.Name.directionClicked,
                    properties: property.dictionary
                )
                
                return .none
                
            case .showUseSpoonPopup:
                if state.spoonCount <= 0 {
                    Mixpanel.mainInstance().track(event: ReviewEvents.Name.spoonUseFailed)
                    
                    return .send(.delegate(.presentToast(.noSpoon)))
                }
                let property = makeReviewProperty(&state)
                
                Mixpanel.mainInstance().track(
                    event: ReviewEvents.Name.spoonUseIntent,
                    properties: property.dictionary
                )
                
                state.isUseSpoonPopupVisible = true
                return .none
                
            case .confirmUseSpoonPopup:
                state.isUseSpoonPopupVisible = false
                // 확인할래요
                let property = makeReviewProperty(&state)
                
                Mixpanel.mainInstance().track(
                    event: ReviewEvents.Name.spoonUsed,
                    properties: property.dictionary
                )
                return .run { [postId = state.postId] send in
                    do {
                        let isSuccess = try await postUseCase.scoopPost(postId: postId)
                        await send(.scoopButtonTappedResponse(isSuccess: isSuccess))
                    } catch {
                        await send(.delegate(.presentToast(.spoonError)))
                    }
                }
                
            case .showDeletePopup:
                state.isDeletePopupVisible = true
                return .none
                
            case .dismissUseSpoonPopup:
                state.isUseSpoonPopupVisible = false
                return .none
                
            case .confirmDeletePopup:
                state.isDeletePopupVisible = false
                return .run { [postId = state.postId] send in
                    do {
                        try await postUseCase.deletePost(postId: postId)
                        await send(.delegate(.presentToast(.reviewDeleteSuccess)))
                        await send(.delegate(.routeToPreviousScreen))
                    } catch {
                        await send(.delegate(.presentToast(.reviewDeleteFail)))
                    }
                }
                
            case .dismissDeletePopup:
                state.isDeletePopupVisible = false
                return .none
                
            case .spoonTapped:
                print("🔍 isFirstVisitOfDay: \(UserManager.shared.isFirstVisitOfDay())")
                if UserManager.shared.isFirstVisitOfDay() { // 지훈쌤이 스푼 뽑았으면 true 라고 했음 // 하 미안합니다
                    print("🔍 스푼 뽑기를 안헀으면 팝업 표시")
                    return .send(.setShowDailySpoonPopup(true))
                } else {
                    print("🔍 스푼 뽑기을 했으면 AttendanceView로 이동")
                    return .send(.delegate(.routeToAttendanceView))
                }
                
            case let .setShowDailySpoonPopup(show):
                print("🔍 setShowDailySpoonPopup: \(show)")
                state.showDailySpoonPopup = show
                if !show {
                    state.drawnSpoon = nil
                    state.spoonDrawError = nil
                    state.isDrawingSpoon = false
                }
                return .none
                
            case .drawDailySpoon:
                state.isDrawingSpoon = true
                state.spoonDrawError = nil
                
                return .run { send in
                    let result = await TaskResult {
                        try await homeService.drawDailySpoon()
                    }
                    await send(.spoonDrawResponse(result))
                }
                
            case let .spoonDrawResponse(.success(response)):
                state.isDrawingSpoon = false
                state.drawnSpoon = response
                
                let property = SpoonEvents.SpoonReceivedProperty(
                    spoonCount: response.spoonType.spoonAmount
                )
                
                Mixpanel.mainInstance().track(
                    event: SpoonEvents.Name.spoonReceived,
                    properties: property.dictionary
                )
                
                return .send(.fetchSpoonCount)
                
            case .fetchSpoonCount:
                return .run { send in
                    let result = await TaskResult { try await homeService.fetchSpoonCount() }
                    await send(.spoonCountResponse(result))
                }
                
            case let .spoonDrawResponse(.failure(error)):
                state.isDrawingSpoon = false
                state.spoonDrawError = error.localizedDescription
                return .none
                
            case let .spoonCountResponse(.success(count)):
                state.spoonCount = count
                return .none
                
            case let .spoonCountResponse(.failure(error)):
                print("Spoon count fetch error: \(error)")
                return .none
                
            case .delegate(.routeToAttendanceView):
                state.showAttendanceView = true
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
    
    private func updateState(_ state: inout State, with data: PostModel) {
        state.userId = data.userId
        state.isZzim = data.isZzim
        state.isScoop = data.isScoop
        state.spoonCount = data.spoonCount
        state.zzimCount = data.zzimCount
        state.postId = data.postId
        state.userName = data.userName
        state.photoUrlList = data.photoUrlList
        state.date = data.date
        state.menuList = data.menuList
        state.description = data.description
        state.placeName = data.placeName
        state.placeAddress = data.placeAddress
        state.latitude = data.latitude
        state.longitude = data.longitude
        state.categoryName = data.categoryColorResponse.categoryName
        state.iconUrl = data.categoryColorResponse.iconUrl ?? ""
        state.categoryColorResponse = data.categoryColorResponse
        state.isMine = data.isMine
        state.profileImageUrl = data.profileImageUrl
        state.regionName = data.regionName
        state.value = data.value
        state.cons = data.cons
        state.isFollowing = data.isFollowing
        
        let property = CommonEvents.ReviewViewedProperty(
            reviewId: state.postId,
            authorUserId: state.userId,
            // MARK: - 임시
            placeId: 1,
            placeName: state.placeName,
            category: state.categoryName,
            menuCount: state.menuList.count,
            satisfaction: state.value,
            reviewLength: state.description.count,
            photoCount: state.photoUrlList.count,
            hasDisappointment: !state.cons.isEmpty,
            savedCount: state.zzimCount,
            isSelfReview: state.isMine,
            isFollowedUserReview: state.isFollowing,
            isSavedReview: state.isZzim,
            // MARK: - 임시
            entryPoint: .explore
        )
        
        Mixpanel.mainInstance().track(
            event: CommonEvents.Name.reviewViewed,
            properties: property.dictionary
        )
    }
    
    private func makeReviewProperty(_ state: inout State) -> ReviewEvents.ReviewProperty {
        let property = ReviewEvents.ReviewProperty(
            reviewId: state.postId,
            authorUserId: state.userId,
            placeId: 1,
            placeName: state.placeName,
            category: state.categoryName,
            menuCount: state.menuList.count,
            satisfactionScore: state.value,
            reviewLength: state.description.count,
            photoCount: state.photoUrlList.count,
            hasDisappointment: !state.cons.isEmpty,
            savedCount: state.zzimCount,
            isFollowingAuthor: state.isFollowing
        )
        
        return property
    }
}
