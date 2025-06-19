//
//  PostFeature.swift
//  Spoony-iOS
//
//  Created by 이명진 on 3/4/25.
//

import ComposableArchitecture

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
        var toast: Toast?
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
        var drawnSpoon: SpoonDrawResponse? = nil
        var spoonDrawError: String? = nil
        
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
        
        case showToast(String)
        case dismissToast
        
        case error(PostError)
        
        case routeToPreviousScreen
        case routeToReportScreen(Int)
        case routeToEditReviewScreen(Int)
        case routeToUserProfileScreen(Int)
        case routeToMyProfileScreen
        
        case showUseSpoonPopup
        case confirmUseSpoonPopup
        case dismissUseSpoonPopup
        
        case showDeletePopup
        case confirmDeletePopup
        case dismissDeletePopup
        
        case spoonTapped
        case routeToAttendanceView
        
        case setShowDailySpoonPopup(Bool)
        case drawDailySpoon
        case spoonDrawResponse(TaskResult<SpoonDrawResponse>)
        case fetchSpoonCount
        case spoonCountResponse(TaskResult<Int>)
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
                    return .send(.showToast("\(error.description)"))
                }
                return .none
                
            case .scoopButtonTapped:
                return .run { [postId = state.postId] send in
                    do {
                        let data = try await postUseCase.scoopPost(postId: postId)
                        await send(.scoopButtonTappedResponse(isSuccess: data))
                    } catch {
                        await send(.error(.spoonError))
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
                        await send(.error(.zzimError))
                    }
                }
                
            case .zzimButtonResponse(let isScrap):
                if isScrap {
                    state.zzimCount += 1
                    state.isZzim.toggle()
                    return .send(.showToast("내 지도에 저장되었어요."))
                } else {
                    state.zzimCount -= 1
                    state.isZzim.toggle()
                    return .send(.showToast("내 지도에서 삭제되었어요."))
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
//                    return .send(.showToast("떠먹기에 성공했어요!"))
                    return .none
                } else {
                    return .send(.showToast("남은 스푼이 없어요 ㅠ.ㅠ"))
                }
                
            case .showToast(let message):
                state.toast = Toast(
                    style: .gray,
                    message: message,
                    yOffset: 539.adjustedH
                )
                
                return .none
                
            case .editButtonTapped:
                return .send(.routeToEditReviewScreen(state.postId))
                
            case .dismissToast:
                state.toast = nil
                return .none
            case .error(let error):
                return .send(.showToast(error.description))
                
            case .routeToReportScreen:
                return .none
                
            case .routeToPreviousScreen:
                return .none
                
            case .routeToEditReviewScreen:
                return .none
                
            case .routeToUserProfileScreen:
                return .none
                
            case .routeToMyProfileScreen:
                return .none
                
            case .showUseSpoonPopup:
                if state.spoonCount <= 0 {
                    return .send(.showToast("남은 스푼이 없어요 ㅠ.ㅠ"))
                }
                state.isUseSpoonPopupVisible = true
                return .none
                
            case .confirmUseSpoonPopup:
                state.isUseSpoonPopupVisible = false
                return .run { [postId = state.postId] send in
                    do {
                        let isSuccess = try await postUseCase.scoopPost(postId: postId)
                        await send(.scoopButtonTappedResponse(isSuccess: isSuccess))
                    } catch {
                        await send(.error(.spoonError))
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
                        await send(.showToast("삭제가 완료되었어요."))
                        await send(.routeToPreviousScreen)
                    } catch {
                        await send(.showToast("삭제에 실패했어요. 다시 시도해주세요."))
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
                    return .send(.routeToAttendanceView)
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
                
            case .routeToAttendanceView:
                state.showAttendanceView = true
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
    }
}
