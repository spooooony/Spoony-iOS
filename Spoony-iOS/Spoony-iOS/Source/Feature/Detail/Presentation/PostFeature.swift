//
//  PostFeature.swift
//  Spoony-iOS
//
//  Created by 이명진 on 3/4/25.
//

import ComposableArchitecture
import Foundation

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
        var isDropDownPresent: Bool = false
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
        case fetchInitialResponse(Result<ReviewDetailModel, APIError>)
        case scoopButtonTapped
        case zzimButtonTapped(isZzim: Bool)
        case showToast(Toast)
        case showDropDown
        case hideDropDown
        case pushNaverMaps
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
                    // 상태 업데이트 로직을 별도 함수로 분리
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
                return .none
                
            case .zzimButtonTapped(let isZzim):
                if isZzim {
                    state.zzimCount -= 1
                } else {
                    state.zzimCount += 1
                }
                
                state.isZzim.toggle()
                return .none
                
            case .showToast(let toast):
                state.toast = toast
                return .none
                
            case .showDropDown:
                state.isDropDownPresent.toggle()
                return .none
                
            case .hideDropDown:
                state.isDropDownPresent = false
                return .none
                
            case .pushNaverMaps:
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
