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
    private let onBackTapped: (() -> Void)?
    private let tappedAction: (() -> Void)?
    
    init(
        style: NavigationBarStyle,
        title: String? = nil,
        searchText: Binding<String> = .constant(""),
        onBackTapped: (() -> Void)? = nil,
        tappedAction: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self._searchText = searchText
        self.onBackTapped = onBackTapped
        self.tappedAction = tappedAction
    }
    
    var body: some View {
        ZStack {
            if style.showsBackButton {
                backButton
            }
            
            switch style {
            case .searchContent:
                searchContent
            case .locationDetail:
                locationDetail
            case .locationTitle:
                locationTitle
            case .detail:
                detail
            case .detailWithChip(let count):
                detailWithChip(count: count)
            case .search:
                searchBar
            case .searchBar:
                searchBar
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
    
    private var searchContent: some View {
        HStack(spacing: 12) {
            LogoChip(type: .small, count: 10)
            
            HStack(spacing: 8) {
                Image(.icSearchGray600)
                
                Text("오늘은 어디서 먹어볼까요?")
                    .foregroundStyle(.gray500)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.body2m)

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
                HStack {
                    Text(title ?? "홍대입구역")
                        .font(.title2sb)
                        .foregroundStyle(.spoonBlack)
                    Image(.icArrowRightGray700)
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            LogoChip(type: .small, count: 99)
                .padding(.trailing, 20)
        }
    }
    
    private var locationTitle: some View {
        HStack {
            let title = title ?? ""
            Text(title.isEmpty ? "홍대입구역" : title)
                .font(.title2b)
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
                .font(.title2b)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            Spacer()
        }
    }
    
    private func detailWithChip(count: Int) -> some View {
        HStack {
            Spacer()
            
            LogoChip(type: .small, count: count)
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
                        Text("마포구,성수동,강남역")
                            .foregroundStyle(.gray600)
                    }
                    .onSubmit {
                        tappedAction?()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(.icCloseGray400)
                            .foregroundStyle(.gray600)
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
}

struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
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
                style: .detailWithChip(count: 42),
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .searchBar,
                searchText: .constant(""),
                onBackTapped: {}
            )
            .border(.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
