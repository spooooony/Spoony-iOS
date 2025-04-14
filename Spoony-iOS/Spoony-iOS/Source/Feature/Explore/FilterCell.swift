//
//  FilterCell.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/14/25.
//

import SwiftUI

struct FilterCell: View {
    private let isLeadingIcon: Bool
    private let isTrailingIcon: Bool
    private let text: String
    
    private var isSelected: Bool = false
    
    init(
        isLeadingIcon: Bool,
        isTrailingIcon: Bool,
        text: String
    ) {
        self.isLeadingIcon = isLeadingIcon
        self.isTrailingIcon = isTrailingIcon
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if isLeadingIcon {
                Image(.icFilterGray400)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .main400 : .gray500)
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            
            Text(text)
                .customFont(.body2sb)
                .foregroundStyle(isSelected ? .main400 : .gray500)
            
            if isTrailingIcon {
                Image(.icArrowDownGray600)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(isSelected ? .main400 : .gray500)
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, isLeadingIcon || isTrailingIcon ? 12 : 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? .main0 : .gray0)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isSelected ? .main400 : .gray100)
                )
        )
    }
}

#Preview {
    FilterCell(isLeadingIcon: false, isTrailingIcon: true, text: "최신순")
}
