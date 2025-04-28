//
//  ChipsContainerViewForFilter.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/25/25.
//

import SwiftUI

import Kingfisher

/// 다중 선택 가능
// TODO: 안용이꺼랑 합쳐서 컴포넌트화 하기 .... 근데 register에서는 단일 선택인데 걍 따로 쓰는게 나을지도?
struct ChipsContainerViewForFilter: View {
    @State private var totalHeight: CGFloat = .zero
    @Binding var selectedItem: [FilterItem]
    
    private let verticalSpacing: CGFloat = 8
    private let horizontalSpacing: CGFloat = 6
    
    private let items: [FilterItem]
    private let selectedIcons: [String]?
    private let icons: [String]?
    
    init(
        selectedItem: Binding<[FilterItem]>,
        items: [FilterItem],
        selectedIcons: [String]? = nil,
        icons: [String]? = nil
    ) {
        self._selectedItem = selectedItem
        self.items = items
        self.selectedIcons = selectedIcons
        self.icons = icons
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    Group {
                        if let selectedIcons, let icons {
                            ChipsView(
                                title: item.title,
                                selectedImageString: selectedIcons[index],
                                imageString: icons[index],
                                isSelected: selectedItem.contains(item))
                        } else {
                            ChipsView(
                                title: item.title,
                                isSelected: selectedItem.contains(item)
                            )
                        }
                    }
                    .alignmentGuide(.leading) { view in
                        if abs(width - view.width) > geometry.size.width {
                            width = 0
                            height -= view.height
                            height -= verticalSpacing
                        }
                        
                        let result = width
                        
                        if item == items.last {
                            width = 0
                        } else {
                            width -= view.width
                            width -= horizontalSpacing
                        }
                        
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        
                        if item == items.last {
                            height = 0
                        }
                        
                        return result
                    }
                    .onTapGesture {
                        if selectedItem.contains(item) {
                            guard let index = selectedItem.firstIndex(of: item) else { return }
                            selectedItem.remove(at: index)
                        } else {
                            selectedItem.append(item)
                        }
                    }
                }
            }
            .background(
                GeometryReader { geomety in
                    Color.clear
                        .onAppear {
                            self.totalHeight = geomety.size.height
                        }
                }
            )
        }
        .frame(height: totalHeight.adjustedH)
    }
}

struct ChipsView: View {
    private var title: String
    private var selectedImageString: String?
    private var imageString: String?
    private var isSelected: Bool
    
    init(
        title: String,
        selectedImageString: String? = nil,
        imageString: String? = nil,
        isSelected: Bool
    ) {
        self.title = title
        self.selectedImageString = selectedImageString
        self.imageString = imageString
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Group {
                if isSelected {
                    if let imageURL = selectedImageString,
                       let url = URL(string: imageURL) {
                        KFImage(url)
                            .resizable()
                    }
                } else {
                    if let imageURL = imageString,
                       let url = URL(string: imageURL) {
                        KFImage(url)
                            .resizable()
                    }
                }
            }
            .frame(width: 16.adjusted, height: 16.adjustedH)
            
            Text(title)
                .customFont(.body2sb)
                .foregroundStyle(isSelected ? .white : .gray600)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .main400 : .gray0)
                .strokeBorder(.gray100)
        }
    }
}
