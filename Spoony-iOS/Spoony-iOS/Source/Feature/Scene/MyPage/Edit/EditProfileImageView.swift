//
//  EditProfileImage.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/31/25.
//

import SwiftUI

import ComposableArchitecture
import Kingfisher

struct EditProfileImageView: View {
    @State private var isFail = false
    private let store: StoreOf<EditProfileFeature>
    private let type: ProfileImageType

    init(store: StoreOf<EditProfileFeature>, type: ProfileImageType) {
        self.store = store
        self.type = type
    }

    var body: some View {
        ZStack {
            profileImageView
            
            if isFail {
                Image(.icImageFail)
                    .resizable()
                    .frame(width: 23.adjusted, height: 23.adjustedH)
            }
            
            overlayView
        }
        .frame(width: 90.adjusted, height: 90.adjustedH)
        .clipShape(Circle())
    }

    @ViewBuilder
    private var profileImageView: some View {
        switch type {
        case let .success(url, _), let .lock(url, _):
            KFImage(url)
                .placeholder {
                    Circle().fill(.gray200)
                }
                .onFailure { _ in
                    isFail = true
                    store.send(.presentToast(message: "이미지 로드에 실패했습니다!"))
                }
                .resizable()
                .fade(duration: 0.3)
        case .fail:
            Circle().fill(.gray200)
                .onAppear {
                    if !store.isLoadError {
                        store.send(.presentToast(message: "이미지 로드에 실패했습니다!"))
                    }
                }
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        switch type {
        case let .success(_, imageLevel), let .lock(_, imageLevel):
            if case .lock = type {
                Color.spoonBlack.opacity(0.5)
                Image(type.imageName)
                    .resizable()
                    .frame(width: 23.adjusted, height: 23.adjustedH)
            } else {
                Circle()
                    .strokeBorder(
                        imageLevel == store.state.imageLevel ? .main400 : .clear,
                        lineWidth: 4.59.adjusted
                    )
            }
        case let .fail(imageLevel):
            Image(type.imageName)
                .resizable()
                .frame(width: 23.adjusted, height: 23.adjustedH)
            
            Circle()
                .strokeBorder(
                    imageLevel == store.state.imageLevel ? .main400 : .clear,
                    lineWidth: 4.59.adjusted
                )
        }
    }
}
