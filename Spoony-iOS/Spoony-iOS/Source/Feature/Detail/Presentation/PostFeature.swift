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
    
    var description: String {
        switch self {
        case .noData:
            return "네트워크 요청에 실패했습니다."
        case .zzimError:
            return "스크랩에 실패했습니다."
        case .spoonError:
            return "떠먹기에 실패 했습니다."
        }
    }
}

@Reducer
struct PostFeature {
    
    @ObservableState
    struct State: Equatable {
        var isZzim: Bool = false
        var isScoop: Bool = true
        var spoonCount: Int = 0
        var zzimCount: Int = 0
        var isLoading: Bool = false
        var successService: Bool = true
        var toast: Toast?
        
        var postId: Int = 0
        var userName: String = ""
        var photoUrlList: [String] = []
        var title: String = ""
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
        var isMine: Bool = false
        var userImageUrl: String = ""
        var regionName: String = ""
    }
    
    enum Action {
        case viewAppear(postId: Int)
        case fetchInitialResponse(Result<ReviewDetailModel, PostError>)
        
        case scoopButtonTapped
        case scoopButtonTappedResponse(isSuccess: Bool)
        
        case zzimButtonTapped(isZzim: Bool)
        case zzimButtonResponse(isScrap: Bool)
        
        case error(PostError)
    }
    
    @Dependency(\.detailUseCase) var detailUseCase: DetailUseCaseProtocol
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewAppear(let postId):
                state.isLoading = true
                return .run { [postId] send in
                    do {
                        let data = try await detailUseCase.fetchInitialDetail(postId: postId)
                        await send(.fetchInitialResponse(.success(data)))
                    } catch {
                        await send(.fetchInitialResponse(.failure(.noData)))
                    }
                }
                
            case .fetchInitialResponse(let result):
                state.isLoading = false
                switch result {
                case .success(let data):
                    state.successService = true
                    updateState(&state, with: data)
                case .failure:
                    state.successService = false
                    state.toast = Toast(
                        style: .gray,
                        message: "데이터를 불러오는데 실패했습니다.",
                        yOffset: 539
                    )
                }
                return .none
                
            case .scoopButtonTapped:
                let postId = state.postId
                
                return .run { send in
                    
                    do {
                        let data = try await detailUseCase.scoopReview(postId: postId)
                        await send(.scoopButtonTappedResponse(isSuccess: data))
                    } catch {
                        await send(.error(.spoonError))
                    }
                }
                
            case .zzimButtonTapped(let isZzim):
                let postId = state.postId
                return .run { send in
                    do {
                        if isZzim {
                            try await detailUseCase.unScrapReview(postId: postId)
                            await send(.zzimButtonResponse(isScrap: false))
                        } else {
                            try await detailUseCase.scrapReview(postId: postId)
                            await send(.zzimButtonResponse(isScrap: true))
                        }
                    } catch {
                        await send(.error(.zzimError))
                    }
                }
                
            case .zzimButtonResponse(let isScrap):
                if isScrap {
                    state.zzimCount += 1
                    state.isZzim = true
                    state.toast = Toast(
                        style: .gray,
                        message: "내 지도에 추가되었어요.",
                        yOffset: 539.adjustedH
                    )
                } else {
                    state.zzimCount -= 1
                    state.isZzim = false
                    state.toast = Toast(
                        style: .gray,
                        message: "내 지도에서 삭제되었어요.",
                        yOffset: 539.adjustedH
                    )
                }
                return .none
                
            case .scoopButtonTappedResponse(let isSuccess):
                if isSuccess {
                    state.isScoop.toggle()
                    state.spoonCount -= 1
                } else {
                    state.toast = Toast(
                        style: .gray,
                        message: "떠먹기 실패했습니다.",
                        yOffset: 539.adjustedH
                    )
                }
                return .none
            case .error(let error):
                state.toast = Toast(
                    style: .gray,
                    message: error.description,
                    yOffset: 539.adjustedH
                )
                return .none
            }
        }
    }
    
    private func updateState(_ state: inout State, with data: ReviewDetailModel) {
        state.isZzim = data.isZzim
        state.isScoop = data.isScoop
        state.spoonCount = data.spoonCount
        state.zzimCount = data.zzimCount
        state.postId = data.postId
        state.userName = data.userName
        state.photoUrlList = data.photoUrlList
        state.title = data.title
        state.date = data.date.toFormattedDateString()
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
        state.userImageUrl = data.userImageUrl
        state.regionName = data.regionName
    }
}

private enum DetailUseCaseKey: DependencyKey {
    static let liveValue: DetailUseCaseProtocol = DefaultDetailUseCase()
    static let testValue: DetailUseCaseProtocol = MockDetailUseCase()
}

extension DependencyValues {
    var detailUseCase: DetailUseCaseProtocol {
        get { self[DetailUseCaseKey.self] }
        set { self[DetailUseCaseKey.self] = newValue }
    }
}
