//
//  PostView.swift
//  Spoony-iOS
//
//  Created by 이명진 on 3/4/25.
//

import SwiftUI
import ComposableArchitecture

struct PostView: View {
    
    // MARK: - Properties
    
    @Bindable private var store: StoreOf<PostFeature>
    
    let postId: Int
    
    init(postId: Int, store: StoreOf<PostFeature>) {
        self.postId = postId
        self.store = store
    }
    
    private let userImage = Image(.icGpsMain)
    
    @State private var isPresented: Bool = false
    @State private var popUpIsPresented: Bool = false
    
    // MARK: - body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    style: .detailWithChip,
                    spoonCount: store.spoonCount,
                    onBackTapped: {
                        store.send(.routeToPreviousScreen)
                    }
                )
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        userProfileSection
                        imageSection
                        reviewSection
                        placeInfoSection
                        howGoodFeelSection
                        hmmJustOneThingSection
                    }
                }
                .simultaneousGesture(dragGesture)
                .onTapGesture {
                    dismissDropDown()
                }
                .overlay(alignment: .topTrailing, content: {
                    dropDownView
                })
                .scrollIndicators(.hidden)
                .toastView(toast: Binding(
                    get: { store.toast },
                    set: { newValue in
                        if newValue == nil {
                            store.send(.dismissToast)
                        }
                    }
                ))
                .onAppear {
                    store.send(.viewAppear(postId: postId))
                }
                
                bottomView
                    .frame(height: 80.adjustedH)
            }

            .toolbar(.hidden, for: .tabBar)
            
            if store.isLoading {
                ZStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .transition(.opacity)
                .animation(.easeInOut, value: store.isLoading)
            }
        }
        .popup(
            popup: Binding(
                get: { store.isUseSpoonPopupVisible ? .useSpoon : nil },
                set: { newValue in
                    if newValue == nil {
                        store.send(.dismissUseSpoonPopup)
                    }
                }
            ),
            confirmAction: { _ in
                store.send(.confirmUseSpoonPopup)
            }
        )
        .navigationBarBackButtonHidden()
    }
}

// MARK: Gesture
extension PostView {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                dismissDropDown()
            }
    }
}

// MARK: Method
extension PostView {
    private func dismissDropDown() {
        isPresented = false
    }
}

// MARK: - Subviews

extension PostView {
    private var userProfileSection: some View {
        HStack(alignment: .center, spacing: 14.adjustedH) {
            
            RemoteImageView(urlString: store.profileImageUrl)
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 48.adjusted, height: 48.adjustedH)
            
            VStack(alignment: .leading, spacing: 4.adjustedH) {
                Text(store.userName)
                    .customFont(.body2b)
                    .foregroundStyle(.black)
                
                Text(store.regionName)
                    .customFont(.caption1m)
                    .foregroundStyle(.gray400)
            }
            
            Spacer()
            
            if !store.isMine {
                // 내 글이 아니면: 팔로우 버튼 + 메뉴
                HStack(spacing: 11.adjusted) {
                    FollowButton(
                        isFollowing: store.isFollowing,
                        action: {
                            store.send(
                                .followButtonTapped(
                                    userId: store.userId,
                                    isFollowing: store.isFollowing
                                )
                            )
                        }
                    )
                    
                    Image(.icMenu)
                        .onTapGesture {
                            isPresented.toggle()
                        }
                }
            } else {
                // 내 글이면: 메뉴 버튼만
                Image(.icMenu)
                    .onTapGesture {
                        isPresented.toggle()
                    }
            }
        }
        .padding(.vertical, 8.adjustedH)
        .padding(.horizontal, 20.adjustedH)
        .padding(.bottom, 24.adjustedH)
        .onTapGesture {
            print("유저 프로필 탭")
        }
    }
    
    @ViewBuilder
    private var imageSection: some View {
        let imageList: [String] = store.photoUrlList
        
        if imageList.isEmpty {
            Rectangle()
                .foregroundStyle(.gray400)
                .frame(width: 335.adjusted, height: 335.adjustedH)
                .cornerRadius(11.16)
                .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
        } else if imageList.count == 1 {
            RemoteImageView(urlString: imageList[0])
                .scaledToFill()
                .frame(width: 335.adjusted, height: 335.adjustedH)
                .cornerRadius(11.16)
                .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10.adjusted) {
                    ForEach(imageList.indices, id: \.self) { index in
                        RemoteImageView(urlString: imageList[index])
                            .scaledToFill()
                            .frame(width: 278.adjusted, height: 278.adjustedH)
                            .cornerRadius(11.16)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 18.adjustedH, trailing: 20.adjusted))
            }
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 18.adjustedH) {
            
            Text((store.isScoop || store.isMine)
                 ? store.description.splitZeroWidthSpace()
                 : (
                    store.description.count > 120
                    ? "\(store.description.prefix(120))...".splitZeroWidthSpace()
                    : store.description.splitZeroWidthSpace()
                 )
            )
            .customFont(.body2m)
            .frame(width: 335.adjusted, alignment: .leading)
            .foregroundStyle(.black)
            
            Text(store.date.toKoreanDateString)
                .customFont(.caption1m)
                .foregroundStyle(.gray400)
        }
        .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 18.adjustedH, trailing: 20.adjusted))
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private var placeInfoSection: some View {
        VStack(spacing: 0) {
            menuInfo
                .background {
                    Rectangle()
                        .cornerRadius(20)
                        .foregroundStyle(.gray0)
                        .frame(maxHeight: .infinity)
                }
                .overlay(alignment: .bottom) {
                    Line()
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: 1.adjustedH,
                                dash: [8.adjusted]
                            )
                        )
                        .foregroundStyle(.gray200)
                        .frame(width: 266.adjusted, height: 1.adjustedH, alignment: .bottom)
                }
            
            locationInfo
                .background {
                    Rectangle()
                        .frame(maxHeight: 134.adjustedH)
                        .cornerRadius(20)
                        .foregroundStyle(.gray0)
                }
            
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.bottom, 18.adjustedH)
    }
    
    // 만족도
    private var howGoodFeelSection: some View {
        VStack(alignment: .leading, spacing: 20.adjustedH) {
            Text("가격 대비 만족도는 어땠나요?")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            SpoonySlider(.constant(store.value))
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.bottom, 18.adjustedH)
    }
    
    // 흠 아쉬워요 섹션
    private var hmmJustOneThingSection: some View {
        ZStack(alignment: .center) {
            baseHmmSection
            
            Group {
                if !(store.isScoop || store.isMine) {
                    SpoonyButton(style: .primary, size: .minusSpoon, title: "스푼 1개 써서 확인하기", isIcon: true, disabled: .constant(false)) {
                        store.send(.showUseSpoonPopup)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    private var baseHmmSection: some View {
        VStack(alignment: .leading, spacing: 16.adjustedH) {
            Text("이거 딱 하나 아쉬워요!")
                .font(.body1b)
                .foregroundStyle(.spoonBlack)
            
            Text("여기...사장님이 레전드 불친절하심. 사장님이 사람을 안좋아하셔서 사장님 눈빛이 매서워요...ㄷㄷ")
                .font(.body2m)
                .foregroundStyle(.gray900)
        }
        .padding(EdgeInsets(
            top: 20.adjustedH,
            leading: 16.adjusted,
            bottom: 8.8.adjustedH,
            trailing: 20.adjusted
        ))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.gray0
                .cornerRadius(20, corners: [.topLeft, .topRight])
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.bottom, 12.adjustedH)
        .blur(radius: (store.isScoop || store.isMine) ? 0 : 12)
    }
    
    private var menuInfo: some View {
        VStack(alignment: .leading, spacing: 12.adjustedH) {
            Text("Menu")
                .customFont(.body1b)
                .foregroundStyle(.spoonBlack)
            menuList(menus: store.menuList)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 20.adjustedH, leading: 16.adjusted, bottom: 28.adjustedH, trailing: 20.adjusted))
    }
    
    private var locationInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12.adjustedH) {
                Text("Location")
                    .customFont(.body1b)
                    .foregroundStyle(.spoonBlack)
                
                Text(store.placeName)
                    .customFont(.title3sb)
                    .foregroundStyle(.spoonBlack)
                
                HStack(spacing: 4.adjusted) {
                    Image(.icMapGray400)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                    
                    Text(store.placeAddress)
                        .customFont(.body2m)
                        .foregroundStyle(.spoonBlack)
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 21.adjustedH, leading: 16.adjusted, bottom: 21.adjustedH, trailing: 16.adjusted))
    }
    
    private var bottomView: some View {
        HStack(spacing: 0) {
            SpoonyButton(
                style: .secondary,
                size: (store.isMine) ? .xlarge : .medium,
                title: "길찾기",
                isIcon: false,
                disabled: .constant(false)
            ) {
                
                let appName: String = "Spoony"
                guard let url = URL(string: "nmap://place?lat=\(store.latitude)&lng=\(store.longitude)&name=\(store.placeName)&appname=\(appName)") else { return }
                let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.open(appStoreURL)
                }
            }
            
            if !store.isMine {
                Spacer()
                
                PostScrapButton(store: store)
            }
        }
        .padding(.horizontal, 20.adjusted)
    }
    
    private var dropDownView: some View {
        Group {
            if isPresented {
                DropDownMenu(
                    items: store.isMine
                    ? ["수정하기", "삭제하기"]
                    : ["신고하기"],
                    isPresented: $isPresented
                ) { selected in
                    if store.isMine {
                        switch selected {
                        case "수정하기":
                            // TODO: 수정 액션
                            print("수정하기 탭됨")
                        case "삭제하기":
                            // TODO: 삭제 액션
                            print("삭제하기 탭됨")
                        default:
                            break
                        }
                    } else {
                        
                        if selected == "신고하기" {                            store.send(.routeToReportScreen(store.postId))
                        }
                    }
                }
                .frame(alignment: .topTrailing)
                .padding(.top, 48.adjustedH)
                .padding(.trailing, 20.adjusted)
            }
        }
    }
    
    private func reviewsErrorView(_ error: String) -> some View {
        VStack {
            Text("리뷰를 불러오는데 실패했습니다.")
                .customFont(.body2m)
                .foregroundStyle(.gray600)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
                .frame(maxWidth: .infinity)
            
            Button("다시 시도") {
                store.send(.viewAppear(postId: postId))
            }
            .buttonStyle(.borderless)
            .foregroundColor(.main400)
            .padding(.top, 8)
        }
    }
}

struct PostScrapButton: View {
    
    private var store: StoreOf<PostFeature>
    
    init(store: StoreOf<PostFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(store.isZzim ? .icAddmapMain400 : .icAddmapGray400)
                .resizable()
                .scaledToFit()
                .frame(width: 32.adjusted, height: 32.adjustedH)
                .onTapGesture {
                    store.send(.zzimButtonTapped(isZzim: store.isZzim))
                }
                .padding(EdgeInsets(top: 1.5, leading: 12, bottom: 4, trailing: 12))
            
            Text("\(store.zzimCount)")
                .customFont(.caption1m)
                .foregroundStyle(store.isZzim ? .main400 : .gray800)
                .padding(.bottom, 1.5)
        }
    }
}

#Preview {
    
    let store = Store(initialState: PostFeature.State()) {
        PostFeature()
            .dependency(\.detailUseCase, DetailUseCaseKey.liveValue)
    }
    
    return PostView(postId: 53, store: store)
}
