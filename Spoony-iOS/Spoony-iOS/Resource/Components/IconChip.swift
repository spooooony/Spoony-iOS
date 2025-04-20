//
//  IconChip.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import SwiftUI

struct IconChip: View {
    let chip: ChipColorEntity
    
    var body: some View {
        HStack(spacing: 4) {
            if let url = URL(string: chip.iconUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16.adjusted, height: 16.adjusted)
                } placeholder: {
                    Color.clear
                        .frame(width: 16.adjusted, height: 16.adjusted)
                }
            } else {
                Color.clear
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            Text(chip.name)
                .customFont(.caption1m)
                .foregroundStyle(Color(hex: chip.textColor))
        }
        .padding(.vertical, 4.adjusted)
        .padding(.horizontal, 10.adjustedH)
        .background(Color(hex: chip.backgroundColor), in: RoundedRectangle(cornerRadius: 12))
        .frame(height: 24.adjustedH)
    }
}
