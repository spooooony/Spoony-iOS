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
    let onBackTapped: (() -> Void)?
    let onSearchSubmit: (() -> Void)?
    let onLikeTapped: (() -> Void)?
    let onLocationTapped: (() -> Void)?
    
    init(
        style: NavigationBarStyle,
        title: String = "",
        searchText: Binding<String> = .constant(""),
        onBackTapped: (() -> Void)? = nil,
        onSearchSubmit: (() -> Void)? = nil,
        onLikeTapped: (() -> Void)? = nil,
        onLocationTapped: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self._searchText = searchText
        self.onBackTapped = onBackTapped
        self.onSearchSubmit = onSearchSubmit
        self.onLikeTapped = onLikeTapped
        self.onLocationTapped = onLocationTapped
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
         .frame(height: 56.adjusted)
         .background(.white)
     }
    
    private var backButtonView: some View {
        Button(action: onBackTapped ?? { print("error") }) {
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
            Button(action: onLocationTapped ?? { print("error") }) {
                HStack {
                    Text(title)
                        .font(.title2b)
                        .foregroundColor(.spoonBlack)
                    Image(.icArrowRightGray700)
                }
            }
            .padding(.leading, 16)
            
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
            
            HStack(spacing: 4) {
                Text("\(count)")
                    .font(.system(size: 14))
                Image(.icSpoonWhite)
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
            Text(title.isEmpty ? "홍대입구역" : title)
                .font(.title2b)
                .foregroundColor(.black)
            Spacer()
            Button(action: onBackTapped ?? { print("error") }) {
                Image(.icCloseGray400)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
    }
}
