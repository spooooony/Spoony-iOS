//
//  CustomNavigationBar.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var searchText: String
    
    private let style: NavigationBarStyle
    private let title: String?
    private let placeholder: String?
    private let tappedAction: (() -> Void)?
    private let onClearTapped: (() -> Void)?
    private var spoonCount: Int = 0
    private var onBackTapped: (() -> Void)?
    private var spoonTapped: (() -> Void)?
    
    init(
        style: NavigationBarStyle,
        title: String? = nil,
        placeholder: String? = nil,
        searchText: Binding<String> = .constant(""),
        spoonCount: Int = 0,
        onBackTapped: (() -> Void)? = nil,
        spoonTapped: (() -> Void)? = nil,
        tappedAction: (() -> Void)? = nil,
        onClearTapped: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.placeholder = placeholder
        self._searchText = searchText
        self.spoonCount = spoonCount
        self.onBackTapped = onBackTapped
        self.spoonTapped = spoonTapped
        self.tappedAction = tappedAction
        self.onClearTapped = onClearTapped
    }
    
    var body: some View {
        ZStack {
            if style.showsBackButton {
                backButton
            }
            
            switch style {
            case .settingContent:
                settingContent
            case .searchContent:
                searchContent
            case .locationDetail:
                locationDetail
            case .locationTitle:
                locationTitle
            case .detail:
                detail
            case .detailWithChip:
                detailWithChip
            case .backOnly:
                EmptyView()
            case .attendanceCheck:
                attendanceCheck
            case .search:
                searchBar
            case .searchBar:
                searchBar
            case .onboarding:
                onboarding
            }
        }
        .frame(height: 56.adjusted)
        .background(.clear)
    }
    
    private var backButtonView: some View {
        Image(.icArrowLeftGray700)
            .onTapGesture {
                onBackTapped?()
            }
    }
    
    private var backButton: some View {
        HStack {
            backButtonView
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var settingContent: some View {
        HStack(spacing: 12) {
            LogoChip(type: .small, count: spoonCount)
                .onTapGesture {
                    spoonTapped?()
                }
            
            Spacer()
            
            Image(.icNavTopPrimaryTwoNone)
                .onTapGesture {
                    tappedAction?()
                }
        }
        .padding(.horizontal, 16)
    }
    
    private var searchContent: some View {
        HStack(spacing: 12) {
            LogoChip(type: .small, count: spoonCount)
            
            HStack(spacing: 8) {
                Image(.icSearchGray600)
                
                Text("오늘은 어디서 먹어볼까요?")
                    .foregroundStyle(.gray500)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .customFont(.body2m)
                
            }
            .padding(.horizontal, 12)
            .frame(height: 44.adjusted)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.gray200)
                    )
            )
            .onTapGesture {
                tappedAction?()
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var locationDetail: some View {
        HStack {
            Button(action: { tappedAction?() }) {
                HStack(spacing: 4) {
                    Text(title ?? "홍대입구역")
                        .customFont(.title3sb)
                        .foregroundStyle(.spoonBlack)
                    Image(.icArrowRightGray700)
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            LogoChip(type: .small, count: spoonCount)
                .padding(.trailing, 20)
        }
    }
    
    private var locationTitle: some View {
        HStack {
            let title = title ?? ""
            Text(title.isEmpty ? "홍대입구역" : title)
                .customFont(.title3b)
                .foregroundStyle(.spoonBlack)
            Spacer()
            Image(.icCloseGray400)
                .foregroundStyle(.gray400)
                .onTapGesture {
                    onBackTapped?()
                }
        }
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .background(.white)
    }
    
    private var detail: some View {
        HStack {
            Spacer()
            Text(title ?? "홍대")
                .customFont(.title3b)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            Spacer()
        }
    }
    
    private var detailWithChip: some View {
        HStack {
            Spacer()
            
            LogoChip(type: .small, count: spoonCount)
                .padding(.trailing, 20)
        }
    }
    
    private var attendanceCheck: some View {
        HStack {
            HStack(spacing: 8) {
                backButtonView
                
                Text("출석체크")
                    .customFont(.title3b)
                    .foregroundStyle(.spoonBlack)
                    .lineLimit(1)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            LogoChip(type: .small, count: spoonCount)
                .padding(.trailing, 20)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            if style.showsBackButton {
                backButtonView
            }
            
            HStack(spacing: 8) {
                Image(.icSearchGray600)
                
                TextField("", text: $searchText)
                    .frame(height: 44.adjusted)
                    .placeholder(when: searchText.isEmpty) {
                        Text(placeholder ?? "마포구,성수동,강남역")
                            .foregroundStyle(.gray600)
                    }
                    .onSubmit {
                        tappedAction?()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onClearTapped?()
                    }) {
                        Image(.icDeleteFillGray400)
                            .resizable()
                            .frame(width: 20.adjusted, height: 20.adjusted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.gray100)
            )
            .cornerRadius(10)
            .frame(height: 44.adjusted)
        }
        .padding(.horizontal, 16)
    }
    
    private var onboarding: some View {
        HStack {
            Spacer()
            
            Text("건너뛰기")
                .underline()
                .customFont(.body2m)
                .foregroundStyle(.gray400)
                .padding(.trailing, 21)
                .onTapGesture {
                    tappedAction?()
                }
        }
    }
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            
            CustomNavigationBar(
                style: .settingContent,
                onBackTapped: {}
            )
            .border(.gray)
            CustomNavigationBar(
                style: .searchContent,
                searchText: .constant("검색어"),
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .locationDetail,
                title: "위치 상세",
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .locationTitle,
                title: "홍대입구역",
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .detail,
                title: "상세 페이지",
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .detailWithChip,
                onBackTapped: {}
            )
            .border(.gray)
            
            // 새로 추가한 뒤로가기만 있는 스타일
            CustomNavigationBar(
                style: .backOnly,
                onBackTapped: {}
            )
            .border(.gray)
            
            // 수정된 출석체크 스타일
            CustomNavigationBar(
                style: .attendanceCheck,
                spoonCount: 11,
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .searchBar,
                searchText: .constant(""),
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .onboarding,
                onBackTapped: {}
            )
            .border(.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
