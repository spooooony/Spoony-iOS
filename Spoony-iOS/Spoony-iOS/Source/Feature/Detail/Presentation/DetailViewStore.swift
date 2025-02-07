//
//  DetailViewStore.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/23/25.
//

import Foundation
import UIKit

final class DetailViewStore: ObservableObject {
    @Published private(set) var state: DetailState = DetailState()
    
    private let detailUseCase: DetailUseCaseProtocol
    
    // TDOO: HomeService 리팩토링 되면 코드 수정
    init(detailUseCase: DetailUseCaseProtocol = DefaultDetailUseCase(detailRepository: DefaultDetailRepository(),
                                                                     homeService: DefaultHomeService())) {
        self.detailUseCase = detailUseCase
    }
    
    // MARK: - Reducer
    
    @MainActor
    func send(intent: DetailIntent) {
        switch intent {
        case .fetchInitialValue(_, let postId):
            Task {
                await fetchInitialData(userId: Config.userId, postId: postId)
            }
        case .scrapButtonDidTap(let isScrap):
            Task {
                await handleScrapButton(isScrap: isScrap)
            }
        case .scoopButtonDidTap:
            Task {
                try await handleScoopButton()
            }
        case .pathInfoInNaverMaps:
            openNaverMaps()
        }
    }
    
    // MARK: - Methods
    
    // 초기 데이터 로드
    @MainActor
    private func fetchInitialData(userId: Int, postId: Int) async {
        Task {
            state.isLoading = true
            do {
                let data = try await detailUseCase.fetchInitialDetail(userId: userId, postId: postId)
                updateState(with: data)
                state.successService = true
            } catch {
                state.toast = Toast(style: .gray, message: "데이터를 불러오는데 실패했습니다.", yOffset: 539.adjustedH)
                state.successService = false
            }
            state.isLoading = false
        }
    }
    
    // State 업데이트
    private func updateState(with data: ReviewDetailModel) {
        state = DetailState(
            postId: data.postId,
            userName: data.userName,
            photoUrlList: data.photoUrlList,
            title: data.title,
            date: String(data.date.prefix(10)),
            menuList: data.menuList,
            description: data.description,
            placeName: data.placeName,
            placeAddress: data.placeAddress,
            latitude: data.latitude,
            longitude: data.longitude,
            zzimCount: data.zzimCount,
            isZzim: data.isZzim,
            isScoop: data.isScoop,
            categoryName: data.categoryColorResponse.categoryName,
            iconUrl: data.categoryColorResponse.iconUrl,
            categoryColorResponse: data.categoryColorResponse,
            isMine: data.isMine,
            spoonCount: data.spoonCount,
            successService: true,
            userImageUrl: data.userImageUrl,
            regionName: data.regionName
        )
    }
    
    // 스크랩 버튼 처리
    @MainActor
    private func handleScrapButton(isScrap: Bool) async {
        
        Task {
            state.isLoading = true
            do {
                if isScrap {
                    try await detailUseCase.unScrapReview(userId: Config.userId, postId: state.postId)
                    state.zzimCount -= 1
                    state.isZzim = false
                    state.toast = Toast(
                        style: .gray,
                        message: "내 지도에서 삭제되었어요.",
                        yOffset: 539.adjustedH
                    )
                } else {
                    try await detailUseCase.scrapReview(userId: Config.userId, postId: state.postId)
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
            state.isLoading = false
        }
    }
    
    // 떠먹기 버튼 처리
    @MainActor
    private func handleScoopButton() async throws {
        Task {
            state.isLoading = true
            do {
                let data = try await detailUseCase.scoopReview(userId: Config.userId, postId: state.postId)
                
                if data {
                    state.isScoop.toggle()
                    state.spoonCount -= 1
                }
                
            } catch {
                print(error.localizedDescription)
            }
            state.isLoading = false
        }
    }
    
    // 네이버 지도 열기
    private func openNaverMaps() {
        let appName: String = "Spoony"
        guard let url = URL(string: "nmap://place?lat=\(state.latitude)&lng=\(state.longitude)&name=\(state.placeName)&appname=\(appName)") else { return }
        let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreURL)
        }
    }
}
