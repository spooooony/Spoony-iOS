//
//  DetailViewStore.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

import Foundation
import UIKit

final class DetailViewStore: ObservableObject {
    
    // MARK: - State
    
    struct DetailState {
        var isZzim: Bool = false
        var isScoop: Bool = false
        var spoonCount: Int = 0
        var zzimCount: Int = 0
        var isLoading: Bool = false
        var successService: Bool = true
        var toast: Toast?
    }
    
    // MARK: - Intent

    enum DetailIntent {
        case fetchInitialValue(postId: Int)
        case scoopButtonDidTap
        case scrapButtonDidTap(isScrap: Bool)
        case pathInfoInNaverMaps
    }
    
    // MARK: - 불변 데이터
    
    struct DetailEntity {
        var postId: Int = 0
        var userName: String = ""
        var photoUrlList: [String] = []
        var title: String = ""
        var date: String = ""
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
    
    @MainActor
    @Published private(set) var state = DetailState()
    
    @Published private(set) var entity = DetailEntity()
    
    private let detailUseCase: DetailUseCaseProtocol
    
    // TDOO: HomeService 리팩토링 되면 코드 수정
    init(detailUseCase: DetailUseCaseProtocol = DefaultDetailUseCase(detailRepository: DefaultDetailRepository(),
                                                                     homeService: DefaultHomeService())) {
        self.detailUseCase = detailUseCase
    }
    
//    init(detailUseCase: DetailUseCaseProtocol = MockDetailUseCase()) {
//        self.detailUseCase = detailUseCase
//    }
    
    // MARK: - Reducer
    
    func send(intent: DetailIntent) {
        switch intent {
        case .fetchInitialValue(let postId):
            Task {
                await fetchInitialData(postId: postId)
            }
        case .scrapButtonDidTap(let isScrap):
            Task {
                await handleScrapButton(isScrap: isScrap)
            }
        case .scoopButtonDidTap:
            Task {
                await handleScoopButton()
            }
        case .pathInfoInNaverMaps:
            openNaverMaps()
        }
    }
    
    // MARK: - Methods
    
    @MainActor
    private func fetchInitialData(postId: Int) async {
        state.isLoading = true
        defer { state.isLoading = false }
        
        do {
            let data = try await detailUseCase.fetchInitialDetail(postId: postId)
            updateEntity(with: data)
            state.successService = true
        } catch {
            state.toast = Toast(style: .gray, message: "데이터를 불러오는데 실패했습니다.", yOffset: 539.adjustedH)
            state.successService = false
        }
    }
    
    @MainActor
    private func updateEntity(with data: ReviewDetailModel) {
        entity = DetailEntity(
            postId: data.postId,
            userName: data.userName,
            photoUrlList: data.photoUrlList,
            title: data.title,
            date: data.date.toFormattedDateString(),
            menuList: data.menuList,
            description: data.description,
            placeName: data.placeName,
            placeAddress: data.placeAddress,
            latitude: data.latitude,
            longitude: data.longitude,
            categoryName: data.categoryColorResponse.categoryName,
            iconUrl: data.categoryColorResponse.iconUrl ?? "",
            categoryColorResponse: data.categoryColorResponse,
            isMine: data.isMine,
            userImageUrl: data.userImageUrl,
            regionName: data.regionName
        )
        
        state = DetailState(
            isZzim: data.isZzim,
            isScoop: data.isScoop,
            spoonCount: data.spoonCount,
            zzimCount: data.zzimCount,
            isLoading: false,
            successService: true,
            toast: nil
        )
    }
    
    // 스크랩 버튼 처리
    @MainActor
    private func handleScrapButton(isScrap: Bool) async {
        state.isLoading = true
        defer { state.isLoading = false }
        
        do {
            if isScrap {
                try await detailUseCase.unScrapReview(postId: entity.postId)
                state.zzimCount -= 1
                state.isZzim = false
                state.toast = Toast(
                    style: .gray,
                    message: "내 지도에서 삭제되었어요.",
                    yOffset: 539.adjustedH
                )
            } else {
                try await detailUseCase.scrapReview(postId: entity.postId)
                state.zzimCount += 1
                state.isZzim = true
                state.toast = Toast(
                    style: .gray,
                    message: "내 지도에 추가되었어요.",
                    yOffset: 539.adjustedH
                )
            }
        } catch {
            state.toast = Toast(
                style: .gray,
                message: "요청에 실패했습니다. 다시 시도해주세요.",
                yOffset: 539.adjustedH
            )
        }
    }
    
    // 떠먹기 버튼 처리
    @MainActor
    private func handleScoopButton() async {
        state.isLoading = true
        defer { state.isLoading = false }
        
        do {
            let data = try await detailUseCase.scoopReview(postId: entity.postId)
            
            if data {
                state.isScoop.toggle()
                state.spoonCount -= 1
            }
            
        } catch {
            state.toast = Toast(
                style: .gray,
                message: "떠먹기 실패했습니다.",
                yOffset: 539.adjustedH
            )
        }
    }
    
    // 네이버 지도 열기
    private func openNaverMaps() {
        let appName: String = "Spoony"
        guard let url = URL(string: "nmap://place?lat=\(entity.latitude)&lng=\(entity.longitude)&name=\(entity.placeName)&appname=\(appName)") else { return }
        let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
}
