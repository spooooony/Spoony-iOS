//
//  FilterCell.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/14/25.
//

import SwiftUI

struct FilterCell: View {
    private let title: String
    private let type: FilterButtonType
    @Binding var selectedFilter: [FilterButtonType]
    
    private var isSelected: Bool {
        return selectedFilter.contains(type)
    }
    
    init(
        title: String,
        type: FilterButtonType,
        selectedFilter: Binding<[FilterButtonType]>
    ) {
        self.title = title
        self.type = type
        self._selectedFilter = selectedFilter
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if type.isLeadingIcon {
                Image(.icFilterGray400)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .main400 : .gray500)
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            
            Text(title)
                .customFont(.body2sb)
                .foregroundStyle(isSelected ? .main400 : .gray500)
            
            if type.isTrailingIcon {
                Image(.icArrowDownGray600)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .main400 : .gray500)
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, type.isLeadingIcon || type.isTrailingIcon ? 12 : 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .main0 : .gray0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? .main400 : .gray100)
                )
        )
        .frame(height: 32.adjustedH)
    }
}

#Preview {
    FilterCell(title: "필터", type: .filter, selectedFilter: .constant([]))
}
