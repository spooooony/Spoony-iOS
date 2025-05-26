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
    let action: () -> Void
    
    @State private var showTooltip: Bool = false
    
    init(day: String, isSelected: Bool, action: @escaping () -> Void) {
        self.day = day
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(isSelected ? Color.main500 : Color.gray100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(isSelected ? Color.main100 : Color.gray200, lineWidth: 8)
                        )
                        .frame(width: 105.adjusted, height: 105.adjustedH)
                    
                    if isSelected {
                        // 출석 완료된 경우
                        Image("selectedAttendance")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80.adjusted, height: 80.adjustedH)
                    } else {
                        // 출석하지 않은 경우
                        Image("unselectedAttendance")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80.adjusted, height: 80.adjustedH)
                    }
                    
                    Text(day)
                        .font(.title3b)
                        .foregroundColor(isSelected ? .main400 : .gray400)
                        .frame(width: 90.adjusted, height: 90.adjustedH, alignment: .topLeading)
                        .padding(.top, 12)
                        .padding(.leading, 16)
                }
                .frame(width: 105.adjusted, height: 105.adjustedH)
            }
            .disabled(isSelected)
            .onTapGesture {
                if isSelected {
                    withAnimation(.spring()) {
                        showTooltip.toggle()
                    }
                } else {
                    action()
                }
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
