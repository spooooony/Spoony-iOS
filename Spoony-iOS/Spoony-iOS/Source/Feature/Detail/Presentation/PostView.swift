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
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let store: StoreOf<PostFeature>
    
    let postId: Int
    
    init(postId: Int, store: StoreOf<PostFeature>) {
        self.postId = postId
        self.store = store
    }
    
    private let userImage = Image(.icCafeBlue)
    
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
                        navigationManager.pop(1)
                    }
                )
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        userProfileSection
                        imageSection
                        reviewSection
                        placeInfoSection
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
            
            RemoteImageView(urlString: store.userImageUrl)
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
                Image(.icMenu)
                    .onTapGesture {
                        isPresented.toggle()
                    }
            }
            
        }
        .padding(EdgeInsets(top: 8.adjustedH, leading: 20.adjusted, bottom: 8.adjustedH, trailing: 20.adjusted))
        .padding(.bottom, 24.adjustedH)
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
                .blur(radius: (store.isScoop || store.isMine) ? 0 : 12)
                .cornerRadius(11.16)
                .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10.adjusted) {
                    ForEach(imageList.indices, id: \.self) { index in
                        RemoteImageView(urlString: imageList[index])
                            .scaledToFill()
                            .frame(width: 278.adjusted, height: 278.adjustedH)
                            .blur(radius: (store.isScoop || store.isMine) ? 0 : 12)
                            .cornerRadius(11.16)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
            }
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 8.adjustedH) {
            
            IconChip(
                chip: store.categoryColorResponse.toEntity()
            )
            
            Text(store.title)
                .customFont(.title1b)
                .foregroundStyle(.black)
            
            Text(store.date)
                .customFont(.caption1m)
                .foregroundStyle(.gray400)
            
            Spacer()
                .frame(height: 16.adjustedH)
            
            Text(
                (store.isScoop || store.isMine)
                ? store.description.splitZeroWidthSpace()
                : (store.description.count > 120
                   ? "\(store.description.prefix(120))...".splitZeroWidthSpace()
                   : store.description.splitZeroWidthSpace())
            )
            .customFont(.body2m)
            .frame(width: 335.adjusted, alignment: .leading)
            .foregroundStyle(.black)
            
        }
        .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
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
        .blur(radius: (store.isScoop || store.isMine) ? 0 : 12)
    }
    
    private var menuInfo: some View {
        VStack(alignment: .leading, spacing: 12.adjustedH) {
            Text("Menu")
                .customFont(.body1b)
                .foregroundStyle(.spoonBlack)
            menuList(menus: store.menuList)
        }
        .padding(EdgeInsets(top: 20.adjustedH, leading: 16.adjusted, bottom: 28.adjustedH, trailing: 20.adjusted))
    }
    
    private var locationInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12.adjustedH) {
                Text("Location")
                    .customFont(.body1b)
                    .foregroundStyle(.spoonBlack)
                
                Text(store.placeName)
                    .customFont(.title2sb)
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
                size: (store.isScoop) ? .medium : .xlarge,
                title: (store.isScoop || store.isMine) ? "길찾기" : "떠먹기",
                isIcon: (store.isScoop || store.isMine) ? false : true,
                disabled: .constant(false)
            ) {
                if store.isScoop {
                    print("🔥네이버 지도로 이동")
                    //                    store.send(.pushNaverMaps)
                } else {
                    navigationManager.popup = .useSpoon(action: {
                        store.send(.scoopButtonTapped)
                    })
                }
            }
            
            if store.isScoop {
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
                    items: ["신고하기"],
                    isPresented: $isPresented
                ) { _ in
                    navigationManager.push(.report(postId: postId))
                }
                .frame(alignment: .topTrailing)
                .padding(.top, 48.adjustedH)
                .padding(.trailing, 20.adjusted)
            }
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
    @Previewable @StateObject var navigationManager = NavigationManager()
    
    PostView(
        postId: 20, store: StoreOf<PostFeature>(initialState: PostFeature.State(), reducer: {
            PostFeature()
        })
    )
    .environmentObject(navigationManager)
    .popup(popup: $navigationManager.popup)
}
