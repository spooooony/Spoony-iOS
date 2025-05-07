//
//  SpoonAttendanceView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/15/25.
//

import SwiftUI

struct SpoonAttendanceView: View {
    let day: String
    let isSelected: Bool
    private let action: () -> Void
    @State private var showTooltip: Bool = false
    
    init(day: String, isSelected: Bool, action: @escaping () -> Void) {
        self.day = day
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Button(action: {
                withAnimation(.spring()) {
                    showTooltip.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.gray100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(Color.gray200, lineWidth: 8)
                        )
                        .frame(width: 105.adjusted, height: 105.adjustedH)
                    
                    Image("unselectedAttendance")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80.adjusted, height: 80.adjustedH)
                    
                    Text(day)
                        .font(.title3b)
                        .foregroundColor(.gray400)
                        .frame(width: 90.adjusted, height: 90.adjustedH, alignment: .topLeading)
                        .padding(.top, 12)
                        .padding(.leading, 16)
                }
                .frame(width: 105.adjusted, height: 105.adjustedH)
            }
            
            if showTooltip {
                SpoonyTooltipView(message: "오늘 2개 적립")
                    .offset(y: 86)
                    .zIndex(1)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            await MainActor.run {
                                withAnimation {
                                    showTooltip = false
                                }
                            }
                        }
                    }
            }
        }
    }
}
