//
//  SpoonyTooltipView.swift
//  Spoony-iOS
//
//  Created on 4/27/25.
//

import SwiftUI

struct SpoonyTooltipView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .customFont(.body2m)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.spoonBlack)
            )
            .overlay(
                Triangle()
                    .fill(Color.spoonBlack)
                    .frame(width: 12.adjusted, height: 6.adjustedH)
                    .rotationEffect(.degrees(0))
                    .offset(y: -6)
                , alignment: .top
            )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
