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
    
    private let detailService = DetailService()
    private let homeService = DefaultHomeService()
    private var userSpoonCount: Int = 0
    private var userInfo: UserInfoModel = .init(userId: 30, userEmail: "", userName: "", userImageUrl: "", regionName: "", createdAt: "", updatedAt: "")
    // MARK: - Reducer
    
    @MainActor
    func send(intent: DetailIntent) {
        switch intent {
        case .getInitialValue(_, let postId):
            Task {
                do {
                    let data = try await homeService.fetchSpoonCount(userId: Config.userId)
                    let userData = try await detailService.getUserInfo(userId: Config.userId)
                    self.userSpoonCount = data
                    self.userInfo = userData
                    state.successService = true
                    
                    await fetchInitialData(userId: Config.userId, postId: postId)
                } catch {
                    state.successService = false
                }
            }
        case .scrapButtonDidTap(let isScrap):
            handleScrapButton(isScrap: isScrap)
        case .scoopButtonDidTap:
            Task {
                try await handleScoopButton()
            }
        case .addButtonDidTap:
            handleAddButton()
        case .pathInfoInNaverMaps:
            openNaverMaps()
        }
    }
    
    // MARK: - Methods
    
    // 초기 데이터 로드
    @MainActor
    private func fetchInitialData(userId: Int, postId: Int) async {
        state.isLoading = true
        do {
            let data = try await detailService.getReviewDetail(userId: userId, postId: postId)
            updateState(with: data)
        } catch {
            state.toast = Toast(style: .gray, message: "데이터를 불러오는데 실패했습니다.", yOffset: 539.adjustedH)
            state.successService = false
        }
        state.isLoading = false
    }
    
    // State 업데이트
    private func updateState(with data: ReviewDetailModel) {
        state = DetailState(
            postId: data.postId,
            userId: data.userId,
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
            spoonCount: self.userSpoonCount,
            successService: true,
            userInfo: self.userInfo
        )
    }
    
    // 스크랩 버튼 처리
    private func handleScrapButton(isScrap: Bool) {
        if isScrap {
            detailService.unScrapReview(userId: state.userId, postId: state.postId)
            state.zzimCount -= 1
            state.isZzim = false
            state.toast = Toast(
                style: .gray,
                message: "내 지도에서 삭제되었어요.",
                yOffset: 539.adjustedH
            )
        } else {
            detailService.scrapReview(userId: state.userId, postId: state.postId)
            state.zzimCount += 1
            state.isZzim = true
            state.toast = Toast(
                style: .gray,
                message: "내 지도에 추가되었어요.",
                yOffset: 539.adjustedH
            )
        }
    }
    
    // 떠먹기 버튼 처리
    @MainActor
    private func handleScoopButton() async throws {
        
        do {
            let data = try await detailService.scoopReview(userId: Config.userId, postId: state.postId)
            
            if data {
                state.isScoop.toggle()
                state.spoonCount -= 1
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // 드롭 다운 버튼 처리
    private func handleAddButton() {
        
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
