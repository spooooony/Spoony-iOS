//
//  CustomNavigationBar.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct CustomNavigationBar: View {
    @Binding var searchText: String
    
<<<<<<< HEAD
    private let style: NavigationBarStyle
    private let title: String?
    private let onBackTapped: (() -> Void)?
    private let tappedAction: (() -> Void)?
=======
    let style: NavigationBarStyle
    let title: String
    let onBackTapped: (() -> Void)?
    let onSearchSubmit: (() -> Void)?
    let onLikeTapped: (() -> Void)?
    let onLocationTapped: (() -> Void)?
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
    
    init(
        style: NavigationBarStyle,
        title: String? = nil,
        searchText: Binding<String> = .constant(""),
        onBackTapped: (() -> Void)? = nil,
<<<<<<< HEAD
        tappedAction: (() -> Void)? = nil
=======
        onSearchSubmit: (() -> Void)? = nil,
        onLikeTapped: (() -> Void)? = nil,
        onLocationTapped: (() -> Void)? = nil
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
    ) {
        self.style = style
        self.title = title
        self._searchText = searchText
        self.onBackTapped = onBackTapped
<<<<<<< HEAD
        self.tappedAction = tappedAction
=======
        self.onSearchSubmit = onSearchSubmit
        self.onLikeTapped = onLikeTapped
        self.onLocationTapped = onLocationTapped
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
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
        .background(.clear)
    }
    
    private var backButtonView: some View {
<<<<<<< HEAD
        Image(.icArrowLeftGray700)
            .onTapGesture {
                tappedAction?()
            }
=======
        Button(action: onBackTapped ?? { print("error") }) {
            Image(.icArrowLeftGray700)
        }
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
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
            LogoChip(type: .small, count: 10)
            
            HStack(spacing: 8) {
                Image(.icSearchGray600)
                
                Text("오늘은 어디서 먹어볼까요?")
                    .foregroundColor(Color(.gray500))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .frame(height: 44.adjustedH)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.gray200), lineWidth: 1)
                    )
            )
            .onTapGesture {
                tappedAction?()
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var locationDetailContent: some View {
        HStack {
<<<<<<< HEAD
            Button(action: {
                tappedAction?()
            }) {
=======
            Button(action: onLocationTapped ?? { print("error") }) {
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
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
    
<<<<<<< HEAD
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
                    tappedAction?()
                }
        }
        .padding(.horizontal, 16)
    }
    
    private var detail: some View {
=======
    private func detailContent(isLiked: Bool) -> some View {
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
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
<<<<<<< HEAD
            
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
                    .strokeBorder(.gray400)
            )
            .cornerRadius(10)
            .frame(height: 44.adjusted)
=======
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
        }
        .padding(.horizontal, 16)
    }
}

<<<<<<< HEAD
// MARK: - Preview
struct CustomNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CustomNavigationBar(
                style: .searchContent,
                searchText: .constant("검색어"),
                tappedAction: {
                    print("Tapped")
                }
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .locationDetail,
                title: "위치 상세",
                tappedAction: {
                    print("Tapped")
                }
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .locationTitle,
                title: "홍대입구역",
                tappedAction: {
                    print("Tapped")
                }
            )
            .border(.gray)
            
            CustomNavigationBar(
                style: .detail,
                title: "상세 페이지",
                tappedAction: {
                    print("Tapped")
                }
            )
            .border(.gray)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
=======
#Preview {
    Home()
>>>>>>> parent of ab6cbd1 (Merge pull request #69 from SOPT-all/style/#66-fixDetailNavigation)
}
