//
//  ToolTipView.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/17/25.
//

import SwiftUI

struct ToolTipView: View {
    @State private var isPresented: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(.icScoopedupWhite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.adjusted, height: 20.adjusted)
                
                Text("장소를 등록하면 수저를 획득할 수 있어요")
                    .font(.body2b)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.main400, in: RoundedRectangle(cornerRadius: 10))
            
            Image(.imagePolygon)
                .resizable()
                .scaledToFill()
                .frame(width: 18.adjusted, height: 16.adjustedH)
                .padding(.top, -6)
        }
        .opacity(isPresented ? 1 : 0)
        .task {
            do {
                try await Task.sleep(for: .seconds(3))
                isPresented = false
            } catch {
                
            }
            
        }
    }
}

#Preview {
    ToolTipView()
}
