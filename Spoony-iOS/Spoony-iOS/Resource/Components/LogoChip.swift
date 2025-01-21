//
//  LogoChip.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/14/25.
//

import SwiftUI

enum LogoType {
    case large
    case small
}

struct LogoChip: View {
    let type: LogoType
    let count: Int
    
    var body: some View {
        HStack(spacing: type == .large ? 6 : 5) {
            Text("\(count)")
                .customFont(type == .large ? .body1sb : .body2sb)
                .foregroundStyle(.white)
            Image(type == .large ? .imageSpoonLarge : .imageSpoonSmall)
                .resizable()
                .scaledToFit()
                .frame(width: type == .large ? 24.adjusted : 20.adjusted)
        }
        .padding(.top, 4)
        .padding(.bottom, type == .large ? 5 : 4)
        .padding(.leading, type == .large ? 12 : 8)
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        .spoonBlack,
                        .spoonBlack,
                        .gray500
                    ]
                ),
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }
}

#Preview {
    LogoChip(type: .small, count: 1)
}
