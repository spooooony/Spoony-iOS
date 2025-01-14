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
                .font(type == .large ? .body1sb : .body2sb)
                .foregroundStyle(.white)
            Image(.icBarBlue)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
        .padding(.top, 4)
        .padding(.bottom, type == .large ? 5 : 4)
        .padding(.leading, type == .large ? 12 : 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.gray500, .black]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            ),
            in: RoundedRectangle(
                cornerRadius: 999
            )
        )
    }
}

#Preview {
    LogoChip(type: .large, count: 1)
}
