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
                }
            }
            .frame(height: 56)
            .background(.white)
        }
    
    private var backButton: some View {
        HStack {
            Button(action: onBackTapped) {
                Image("ic_arrow_left_gray700")
                    .frame(width: 24, height: 24)
            }
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
        HStack {
            Image(.icSearchGray600)
            
            TextField("", text: $searchText)
                .placeholder(when: searchText.isEmpty) {
                    Text("플레이스 홀더")
                }
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(.icDeleteGray400)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.gray)
        .cornerRadius(10)
    }
    
    private var locationContent: some View {
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
            
            // TODO: 주리 컴포넌트 작업 다하면 이후 가져다 넣기
            Text("99+")
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black)
                .cornerRadius(12)
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
            
            // TODO: 주리 컴포넌트 작업 다하면 이후 가져다 넣기
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 14))
                Image("ic_spoon_white")
                    .frame(width: 16, height: 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.spoonBlack)
            .foregroundColor(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var locationTitleContent: some View {
        HStack {
            Text(title.isEmpty ? "홍대입구역" : title)  // title이 비어있으면 기본값 사용
                .font(.title2b)
                .foregroundColor(.black)
            Spacer()
            Button(action: onBackTapped) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
    }
}

// TextField placeholder를 위한 extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    DetailView()
}
