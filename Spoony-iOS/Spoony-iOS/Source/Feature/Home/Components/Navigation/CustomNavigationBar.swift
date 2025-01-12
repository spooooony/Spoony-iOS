//
//  CustomNavigationBar.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    let style: NavigationBarStyle
    let title: String
    @Binding var searchText: String
    let onBackTapped: () -> Void
    let onSearchSubmit: (() -> Void)?
    
    init(
        style: NavigationBarStyle,
        title: String = "",
        searchText: Binding<String> = .constant(""),
        onBackTapped: @escaping () -> Void,
        onSearchSubmit: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self._searchText = searchText
        self.onBackTapped = onBackTapped
        self.onSearchSubmit = onSearchSubmit
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBackTapped) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
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