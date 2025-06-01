//
//  EditProfileView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/13/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators
import Kingfisher

struct EditProfileView: View {
    @Bindable private var store: StoreOf<EditProfileFeature>
    
    init(store: StoreOf<EditProfileFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                style: .backOnly,
                searchText: .constant(""),
                onBackTapped: {
                    store.send(.routeToPreviousScreen)
                }
            )
            
            if store.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                sectionContainerView
                    
            }
        }
        .background(.white)
        .onTapGesture {
            hideKeyboard()
            store.send(.checkNickname)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $store.isPresentProfileBottomSheet) {
            ProfileImageBottomSheet(
                isPresented: $store.isPresentProfileBottomSheet,
                profileImages: store.profileImages
            )
            .presentationDetents([.height(629.adjustedH)])
            .presentationCornerRadius(14)
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
}

extension EditProfileView {
    private var sectionContainerView: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileSection
                
                nicknameSection
                
                introductionSection
                
                birthDateSection
                
                locationSection
                
                SpoonyButton(
                    style: .primary,
                    size: .xlarge,
                    title: "저장",
                    disabled: $store.isDisableRegisterButton
                ) {
                    store.send(.didTapRegisterButton)
                }
                .unredacted()
                .padding(.bottom, 25)
            }
            .disabled(store.state.isLoadError)
            .redacted(reason: store.state.isLoadError ? .placeholder : [])
        }
        .scrollIndicators(.hidden)
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 5) {
                Text("프로필 이미지")
                    .font(.title3sb)
                    .foregroundStyle(.spoonBlack)
                
                Button {
                    store.send(.didTapQuesetionButton)
                } label: {
                    Image(.icQuestionGray300)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjustedH)
                }
            }
            .padding(.horizontal, 20)
            .unredacted()
            
            profileImageList
        }
        .padding(.top, 5)
        .padding(.bottom, 41)
    }
    
    private var profileImageList: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(store.profileImages, id: \.self) { image in
                    profileImageCell(image)
                        .onTapGesture {
                            if image.isUnlocked {
                                store.send(.didTapProfileImage(image))
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
    }
    
    private func profileImageCell(_ image: ProfileImage) -> some View {
        Group {
            if image.isUnlocked {
                if let url = URL(string: image.url) {
                    EditProfileImageView(store: store, type: .success(url, image.imageLevel))
                } else {
                    EditProfileImageView(store: store, type: .fail(image.imageLevel))
                }
            } else {
                EditProfileImageView(store: store, type: .lock)
            }
        }
    }
}

extension EditProfileView {
    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("닉네임을 입력해 주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .unredacted()
            
            NicknameTextField(
                errorState: $store.nicknameErrorState,
                text: $store.userNickname,
                isError: $store.isNicknameError
            )
            .onSubmit {
                store.send(.checkNickname)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("간단한 자기소개를 입력해 주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .unredacted()
            
            SpoonyTextEditor(
                text: $store.introduction,
                style: .profileEdit,
                placeholder: "",
                isError: .constant(false)
            )
        }
        .padding(.bottom, 32)
    }
    
    private var birthDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("생년월일을 입력해 주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .unredacted()
            
            SpoonyDatePicker(selectedDate: $store.birthDate)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주로 활동하는 지역을 설정해주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .unredacted()
            
            SpoonyLocationPicker(
                locationList: store.regionList,
                selectedLocation: $store.selectedLocation,
                selectedSubLocation: $store.selectedSubLocation
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 35)
    }
}

#Preview {
    NavigationView {
        EditProfileView(store: Store(initialState: .initialState, reducer: {
            EditProfileFeature()
            
        }))
    }
}
