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
        HStack(spacing: 12) {
            Button(action: onBackTapped) {
                Image("ic_arrow_left_gray700")
                    .frame(width: 24, height: 24)
            }
            
            switch style {
            case .primary:
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                }
                Spacer()
                
            case .search:
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("플레이스 홀더")
                                .foregroundColor(.gray)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
            case .location:
                Button(action: {}) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                Text("99+")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black)
                    .cornerRadius(12)
                
            case .detail(let isLiked):
                HStack {
                    Button(action: onBackTapped) {
                        Image("ic_arrow_left_gray700")
                            .frame(width: 24, height: 24)
                    }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.title2b)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: { onLikeTapped?() }) {
                            Image(isLiked ? "ic_heart_filled" : "ic_heart")
                                .frame(width: 24, height: 24)
                        }
                        
                        Button(action: {}) {
                            Image("ic_share")
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                
            case .detailWithChip(let count):
                Spacer()
                
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
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Color.white)
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
