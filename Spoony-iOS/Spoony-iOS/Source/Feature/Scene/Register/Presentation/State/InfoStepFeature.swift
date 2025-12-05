//
//  InfoStepFeature.swift
//  Spoony-iOS
//
//  Created by 최안용 on 3/21/25.
//

import Foundation

import ComposableArchitecture
import Mixpanel

@Reducer
struct InfoStepFeature {
    @ObservableState
    struct State: Equatable {
        static let initialState = State()
        static var editState: State {
            var state = State()
            state.isEditMode = true
            state.isDisableNextButton = false
            return state
        }
        
        var isEditMode: Bool = false
        var selectedCategoryId: Int?
        
        var isLoadError: Bool = false
        
        // MARK: - 카테고리 관련 property
        var selectedCategory: [CategoryChipEntity] = []
        var categories: [CategoryChipEntity] = []

        // MARK: - 검색 관련 property
        var placeText: String = ""
        var searchedPlaces: [PlaceInfoEntity] = []
        var selectedPlace: PlaceInfoEntity?
        var isDropDownPresented: Bool = false
        
        // MARK: - 추천 메뉴 관련 property
        var recommendTexts: [RecommendText] = [.init()]
        var isDisablePlusButton: Bool = false
        
        // MARK: - 만족도 property
        var satisfaction: Double = 50.0
        
        var keyboardHeight: CGFloat = 0
        var isDisableNextButton: Bool = true
    }
    
    enum Action: BindableAction, Equatable {
        case onAppear
        case binding(BindingAction<State>)
        
        case updateIsLoadError(Bool)
        
        // MARK: - 카테고리 관련 이벤트
        case categoryResponse([CategoryChipEntity])
        case loadSelectedCategory
        
        // MARK: - 검색 관련 이벤트
        case didTapSearchDeleteIcon
        case didTapKeyboardEnter
        case searchPlaceResponse([PlaceInfoEntity])
        case didTapPlaceInfoCell(PlaceInfoEntity)
        case didTapPlaceInfoCellIcon
        case updatePlace(PlaceInfoEntity?)
        case didTapNextButton
        
        // MARK: - 추천 메뉴 관련 이벤트
        case didTapRecommendPlusButton
        case didTapRecommendDeleteButton(RecommendText)
        case updatePlusButtonState
        
        case validateNextButton
        case didTapBackground
        case updateKeyboardHeight(CGFloat)
        
        // MARK: - Route Action: 화면 전환 이벤트를 상위 Reducer에 전달 시 사용
        case delegate(Delegate)
        enum Delegate: Equatable {
            case presentToast(ToastType)
        }
    }
    
    @Dependency(\.getCategoriesUseCase) var getCategoriesUseCase: GetCategoriesUseCaseProtocol
    @Dependency(\.searchPlaceUseCase) var searchPlaceUseCase: SearchPlaceUseCaseProtocol
    @Dependency(\.validatePlaceUseCase) var validatePlaceUseCase: ValidatePlaceUseCaseProtocol
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let categories = try await getCategoriesUseCase.execute()
                        
                        await send(.categoryResponse(categories))
                    } catch {
                        await send(.delegate(.presentToast(.serverError)))
                        await send(.updateIsLoadError(true))
                    }
                }
                
            case .binding(\.recommendTexts):
                return .send(.validateNextButton)
            case .binding(\.selectedCategory):
                return .send(.validateNextButton)
            case .binding: return .none
            case .updateIsLoadError(let isLoadError):
                state.isLoadError = isLoadError
                state.isDisableNextButton = true
                return .none
            case .loadSelectedCategory:
                if let selectedId = state.selectedCategoryId,
                   let selectedCategory = state.categories.first(where: { $0.id == selectedId }) {
                    state.selectedCategory = [selectedCategory]
                }
                
                return .none
            case .categoryResponse(let value):
                state.categories = value
                if state.isEditMode {
                    return .send(.loadSelectedCategory)
                } else {
                    return .none
                }
            case .didTapSearchDeleteIcon:
                state.placeText = ""
                return .none
            case .didTapKeyboardEnter:
                let searchText = state.placeText
                
                return .run { [searchText] send in
                    do {
                        let places = try await searchPlaceUseCase.execute(query: searchText)
                        
                        await send(.searchPlaceResponse(places))
                    } catch {
                        await send(.delegate(.presentToast(.serverError)))
                    }
                }
            case .searchPlaceResponse(let places):
                state.isDropDownPresented = !places.isEmpty
                state.searchedPlaces = places
                return places.isEmpty ? .send(.delegate(.presentToast(.noSearchResult))) : .none
            case .didTapPlaceInfoCell(let place):
                return .run { [latitude = place.latitude, longitude = place.longitude] send in
                    do {
                        let isDuplicate = try await validatePlaceUseCase.execute(
                            latitude: latitude,
                            longitude: longitude
                        )
                        
                        if isDuplicate {
                            await send(.updatePlace(nil))
                            await send(.delegate(.presentToast(.alreadyRegistered)))
                        } else {
                            await send(.updatePlace(place))
                        }
                    }
                }
            case .updatePlace(let place):
                state.selectedPlace = place
                state.isDropDownPresented = false
                state.placeText = ""
                
                return .send(.validateNextButton)
            case .didTapPlaceInfoCellIcon:
                state.selectedPlace = nil
                
                return .send(.validateNextButton)
            case .didTapRecommendPlusButton:
                guard !state.isDisablePlusButton else { return .none }
                
                state.isDisablePlusButton = true
                
                state.recommendTexts.append(.init())
                
                return .run { send in
                    await send(.validateNextButton)
                    
                    do {
                        try await Task.sleep(for: .seconds(0.5))
                        
                        await send(.updatePlusButtonState)
                    } catch {
                        await send(.delegate(.presentToast(.unknownError)))
                    }
                }
            case .didTapRecommendDeleteButton(let text):
                if let index = state.recommendTexts.firstIndex(where: { $0.id == text.id }),
                   state.recommendTexts.count != 1 {
                    state.recommendTexts.remove(at: index)
                }
                return .send(.validateNextButton)
            case .updatePlusButtonState:
                state.isDisablePlusButton = false
                return .none
            case .didTapNextButton:
                if !state.isEditMode {
                    guard let categoryName = state.selectedCategory.first?.title,
                          let placeName = state.selectedPlace?.placeName else { return .none }
                    let property = RegisterEvents.Review1Property(
                        placeName: placeName,
                        category: categoryName,
                        menuCount: state.recommendTexts.count
                    )
                    
                    Mixpanel.mainInstance().track(
                        event: RegisterEvents.Name.reivew1Complete,
                        properties: property.dictionary
                    )
                }
                
                return .none
            case .validateNextButton:
                let isRecommendMenuInvalid = state.recommendTexts.contains(where: { $0.text.isEmpty })
                let isSelectedCategoryInvalid = state.selectedCategory.isEmpty
                
                let isSelectedPlaceInvalid = state.selectedPlace == nil
                
                state.isDisableNextButton = isRecommendMenuInvalid || isSelectedCategoryInvalid || isSelectedPlaceInvalid
                return .none
            case .didTapBackground:
                state.isDropDownPresented = false
                return .none
            case .updateKeyboardHeight(let height):
                state.keyboardHeight = height
                return .none
            default:
                return .none
            }
        }
    }
}
