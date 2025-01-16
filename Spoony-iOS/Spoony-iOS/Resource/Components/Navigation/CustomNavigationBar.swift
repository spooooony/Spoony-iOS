//
//  CustomNavigationBar.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var searchText: String
    
    let style: NavigationBarStyle
    let title: String
    let onBackTapped: () -> Void
    let onSearchSubmit: (() -> Void)?
    let onLikeTapped: (() -> Void)?
    
    init(
        style: NavigationBarStyle,
        title: String = "",
        searchText: Binding<String> = .constant(""),
        onBackTapped: @escaping () -> Void,
        onSearchSubmit: (() -> Void)? = nil,
        onLikeTapped: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self._searchText = searchText
        self.onBackTapped = onBackTapped
        self.onSearchSubmit = onSearchSubmit
        self.onLikeTapped = onLikeTapped
    }
    
    var body: some View {
        ZStack {
            if style.showsBackButton {
                backButton
            }
            
            switch style {
            case .primary:
                primaryContent
            case .search:
                searchContent
            case .locationDetail:
                locationDetailContent
            case .locationTitle:
                locationTitleContent
            case .detail(let isLiked):
                detailContent(isLiked: isLiked)
            case .detailWithChip(let count):
                detailWithChipContent(count: count)
            case .searchBar:
                searchBarContent
            }
        }
        .frame(height: 56.adjusted)
        .background(.white)
    }
    
    private var backButtonView: some View {
        Button(action: onBackTapped) {
            Image(.icArrowLeftGray700)
        }
    }
    
    private var backButton: some View {
        HStack {
            backButtonView
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var primaryContent: some View {
        HStack {
            if !title.isEmpty {
                Text(title)
                    .font(.title2b)
            }
            Spacer()
        }
    }
    
    private var searchContent: some View {
        HStack(spacing: 12) {
            if style.showsBackButton {
                backButtonView
            }
            
            HStack(spacing: 8) {
                Image(.icSearchGray600)
                
                TextField("", text: $searchText)
                    .frame(height: 44.adjusted)
                    .placeholder(when: searchText.isEmpty) {
                        Text("플레이스 홀더")
                            .foregroundColor(Color(.gray600))
                    }
                    .onSubmit {
                        onSearchSubmit?()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(.icCloseGray400)
                            .foregroundColor(Color(.gray600))
                    }
                }
            }
            .padding(.horizontal, 12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.gray600), lineWidth: 1)
            )
            .frame(height: 44.adjusted)
        }
        .padding(.horizontal, 16)
    }
    
    private var locationDetailContent: some View {
        HStack {
            Button(action: {}) {
                HStack {
                    Text(title)
                        .font(.title2b)
                        .foregroundColor(.spoonBlack)
                    Image(.icArrowRightGray700)
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            LogoChip(type: .small, count: 99)
                .padding(.trailing, 20)
        }
    }
    
    private func detailContent(isLiked: Bool) -> some View {
        HStack {
            Spacer()
            Text(title)
                .font(.title2b)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            Spacer()
        }
    }
    
    private func detailWithChipContent(count: Int) -> some View {
        HStack {
            Spacer()
            
            LogoChip(type: .small, count: count)
                .padding(.trailing, 20)
        }
    }
    
    private var locationTitleContent: some View {
        HStack {
            Text(title.isEmpty ? "홍대입구역" : title)
                .font(.title2b)
                .foregroundColor(.black)
            Spacer()
            Button(action: onBackTapped) {
                Image(.icCloseGray400)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var searchBarContent: some View {
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
                            .foregroundColor(Color(.gray600))
                    }
                    .onSubmit {
                        onSearchSubmit?()
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(.icCloseGray400)
                            .foregroundColor(Color(.gray600))
                    }
                }
                
            }
            .padding(.horizontal, 12)
            .background(Color(.white))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.gray400), lineWidth: 1)
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
                style: .primary,
                title: "Primary 스타일",
                onBackTapped: {}
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .searchBar,
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
                style: .detail(isLiked: true),
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
