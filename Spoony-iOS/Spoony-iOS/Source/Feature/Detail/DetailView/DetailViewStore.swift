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
    
    private let service = DetailService()
    
    func send(intent: DetailIntent) {
        switch intent {
        case .getInitialValue(let userId, let postId):
            fetchInitialData(userId: userId, postId: postId)
        case .scrapButtonDidTap(let isScrap):
            handleScrapButton(isScrap: isScrap)
        case .scoopButtonDidTap:
            handleScoopButton()
        case .addButtonDidTap:
            handleAddButton()
        case .pathInfoInNaverMaps:
            openNaverMaps()
        }
    }
    
    // 초기 데이터 로드
    private func fetchInitialData(userId: Int, postId: Int) {
        state.isLoading = true
        service.getReviewDetail(userId: userId, postId: postId) { [weak self] result in
            DispatchQueue.main.async {
                self?.state.isLoading = false
                switch result {
                case .success(let data):
                    self?.updateState(with: data)
                case .failure:
                    self?.state.toast = Toast(style: .gray, message: "데이터를 불러오는데 실패했습니다.", yOffset: 539.adjustedH)
                }
            }
        }
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
            isMine: data.isMine
        )
    }
    
        // 스크랩 버튼 처리
        private func handleScrapButton(isScrap: Bool) {
            if isScrap {
                service.unScrapReview(userId: state.userId, postId: state.postId)
                state.zzimCount -= 1
                state.isZzim = false
                state.toast = Toast(
                    style: .gray,
                    message: "내 지도에서 삭제되었어요.",
                    yOffset: 539.adjustedH
                )
            } else {
                service.scrapReview(userId: state.userId, postId: state.postId)
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
    private func handleScoopButton() {
        service.scoopReview(userId: state.userId, postId: state.postId)
//        state.isScoop = true
        
        self.fetchInitialData(userId: state.userId, postId: state.postId)
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
