//
//  DetailView.swift
//  SpoonMe
//
//  Created by 이명진 on 1/2/25.
//

import SwiftUI

enum SNError: Error {
    case networkFail
    case decodeError
    case etc
}

struct DetailView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var navigationManager: NavigationManager
    
    // ObservableObject 쓰면 안돼! 초기화가 되버림.
    // StateObeject 는 초기화가 안됌 상태가 유지가 됌
    @StateObject private var store: DetailViewStore = DetailViewStore()
    let postId: Int
    
    init( postId: Int) {
        self.postId = postId
    }
    
    private let userImage = Image(.icCafeBlue)
    
    @State private var isPresented: Bool = false
    @State private var popUpIsPresented: Bool = false
    @State private var toastMessage: Toast?
    
    // MARK: - body
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detailWithChip,
                spoonCount: store.state.spoonCount,
                onBackTapped: {
                    navigationManager.dispatch(.pop(1))
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
            .toastView(toast: $toastMessage)
            .onAppear {
                store.send(intent: .getInitialValue(userId: Config.userId, postId: postId))
                
                if !store.state.successService {
                    navigationManager.pop(1)
                }
                
            }
            .onChange(of: store.state.toast) { _, newValue in
                toastMessage = newValue
            }
            
            bottomView
                .frame(height: 80.adjustedH)
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: Gesture
extension DetailView {
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { _ in
                dismissDropDown()
            }
    }
}

// MARK: Method
extension DetailView {
    private func dismissDropDown() {
        isPresented = false
    }
}

// MARK: - Subviews

extension DetailView {
    private var userProfileSection: some View {
        HStack(alignment: .center, spacing: 14.adjustedH) {
            
            Image(.imageThingjin)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 48.adjusted, height: 48.adjustedH)
            
            VStack(alignment: .leading, spacing: 4.adjustedH) {
                Text(store.state.userName)
                    .customFont(.body2b)
                    .foregroundStyle(.black)
                
                Text("서울시 성동구 수저")
                    .customFont(.caption1m)
                    .foregroundStyle(.gray400)
            }
            
            Spacer()
            
            if !store.state.isMine {
                Image(.icMenu)
                    .onTapGesture {
                        isPresented.toggle()
                    }
            }
            
        }
        .padding(EdgeInsets(top: 8.adjustedH, leading: 20.adjusted, bottom: 8.adjustedH, trailing: 20.adjusted))
        .padding(.bottom, 24.adjustedH)
    }
    
    private var imageSection: some View {
        let imageList: [String] = store.state.photoUrlList
        
        return Group {
            if imageList.isEmpty {
                // Placeholder 뷰를 사용해 레이아웃 유지
                Rectangle()
                    .foregroundStyle(.gray400)
                    .frame(width: 335.adjusted)
                    .frame(height: 335.adjustedH)
                    .cornerRadius(11.16)
                    .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
            } else if imageList.count == 1 {
                RemoteImageView(urlString: imageList[0])
                    .scaledToFill()
                    .frame(width: 335.adjusted)
                    .frame(height: 335.adjustedH)
                    .blur(radius: (store.state.isScoop || store.state.isMine) ? 0 : 12)
                    .cornerRadius(11.16)
                    .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10.adjusted) {
                        ForEach(imageList.indices, id: \.self) { index in
                            RemoteImageView(urlString: imageList[index])
                                .scaledToFill()
                                .frame(width: 278.adjusted)
                                .frame(height: 278.adjustedH)
                                .blur(radius: (store.state.isScoop || store.state.isMine) ? 0 : 12)
                                .cornerRadius(11.16)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 20.adjusted, bottom: 32.adjustedH, trailing: 20.adjusted))
                }
            }
        }
    }
    
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 8.adjustedH) {
            
            IconChip(
                chip: store.state.categoryColorResponse.toEntity()
            )
            
            Text(store.state.title)
                .customFont(.title1b)
                .foregroundStyle(.black)
            
            Text(store.state.date)
                .customFont(.caption1m)
                .foregroundStyle(.gray400)
            
            Spacer()
                .frame(height: 16.adjustedH)
            
            Text(
                (store.state.isScoop || store.state.isMine)
                ? store.state.description.splitZeroWidthSpace()
                : (store.state.description.count > 120
                   ? "\(store.state.description.prefix(120))...".splitZeroWidthSpace()
                   : store.state.description.splitZeroWidthSpace())
            )
            .customFont(.body2m)
            .frame(width: 335.adjusted)
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
        .blur(radius: (store.state.isScoop || store.state.isMine) ? 0 : 12)
    }
    
    private var menuInfo: some View {
        VStack(alignment: .leading, spacing: 12.adjustedH) {
            Text("Menu")
                .customFont(.body1b)
                .foregroundStyle(.spoonBlack)
            menuList(menus: store.state.menuList)
        }
        .padding(EdgeInsets(top: 20.adjustedH, leading: 16.adjusted, bottom: 28.adjustedH, trailing: 20.adjusted))
    }
    
    private var locationInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12.adjustedH) {
                Text("Location")
                    .customFont(.body1b)
                    .foregroundStyle(.spoonBlack)
                
                Text(store.state.placeName)
                    .customFont(.title2sb)
                    .foregroundStyle(.spoonBlack)
                
                HStack(spacing: 4.adjusted) {
                    Image(.icMapGray400)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                    
                    Text(store.state.placeAddress)
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
                size: (store.state.isScoop) ? .medium : .xlarge,
                title: (store.state.isScoop || store.state.isMine) ? "길찾기" : "떠먹기",
                isIcon: (store.state.isScoop || store.state.isMine) ? false : true,
                disabled: .constant(false)
            ) {
                print("⭐️")
                
                if store.state.isScoop {
                    store.send(intent: .pathInfoInNaverMaps)
                } else {
                    // action 어떻게 하묘
                    navigationManager.dispatch(.showPopup(.useSpoon(action: {
                        store.send(intent: .scoopButtonDidTap)
                    })))
                }
                
                print("⭐️")
            }
            
            if store.state.isScoop {
                Spacer()
                
                ScrapButton(store: store)
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
                    navigationManager.dispatch(.push(.report(postId: store.state.postId)))
                }
                .frame(alignment: .topTrailing)
                .padding(.top, 48.adjustedH)
                .padding(.trailing, 20.adjusted)
            }
        }
    }
}

struct menuList: View {
    var menus: [String] = ["고등어봉초밥", "고등어봉초밥", "고등어봉초밥"]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<menus.count, id: \.self) { index in
                HStack(spacing: 4) {
                    Image(.icSpoonGray600)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                    Text(menus[index])
                        .customFont(.body2m)
                        .lineLimit(2)
                    Spacer()
                }
            }
        }
    }
}

struct ScrapButton: View {
    
    @ObservedObject private var store: DetailViewStore
    
    init(store: DetailViewStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(store.state.isZzim ? .icAddmapMain400 : .icAddmapGray400)
                .resizable()
                .scaledToFit()
                .frame(width: 32.adjusted, height: 32.adjustedH)
                .onTapGesture {
                    store.send(intent: .scrapButtonDidTap(isScrap: store.state.isZzim))
                }
                .padding(EdgeInsets(top: 1.5, leading: 12, bottom: 4, trailing: 12))
            
            Text("\(store.state.zzimCount)")
                .customFont(.caption1m)
                .foregroundStyle(store.state.isZzim ? .main400 : .gray800)
                .padding(.bottom, 1.5)
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
