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
    let spoonDrawResponse: SpoonDrawResponse? 
    
    @State private var showTooltip: Bool = false
    
    init(
        day: String,
        isSelected: Bool,
        spoonDrawResponse: SpoonDrawResponse? = nil,
        action: @escaping () -> Void
    ) {
        self.day = day
        self.isSelected = isSelected
        self.spoonDrawResponse = spoonDrawResponse
        self.action = action
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(isSelected ? Color.main100 : Color.gray100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(isSelected ? Color.main200 : Color.gray200, lineWidth: 8)
                        )
                        .frame(width: 105.adjusted, height: 105.adjustedH)
                    
                    if isSelected {
                        if let spoonResponse = spoonDrawResponse,
                           !spoonResponse.spoonType.spoonImage.isEmpty {
                            AsyncImage(url: URL(string: spoonResponse.spoonType.spoonImage)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image("selectedAttendance")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 80.adjusted, height: 80.adjustedH)
                        } else {
                            Image("selectedAttendance")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80.adjusted, height: 80.adjustedH)
                        }
                    } else {
                        Image("unselectedAttendance")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80.adjusted, height: 80.adjustedH)
                    }
                    
                    Text(day)
                        .font(.title3b)
                        .foregroundColor(isSelected ? .main300 : .gray400)
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
                SpoonyTooltipView(message: getTooltipMessage())
                    .offset(y: 86)
                    .zIndex(1)
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3초
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
    
    private func getSpoonDisplayName(_ spoonName: String) -> String {
        switch spoonName.lowercased() {
        case "plastic":
            return "일회용 티스푼"
        case "silver":
            return "은수저"
        case "gold":
            return "금수저"
        case "diamond":
            return "다이아몬드 수저"
        default:
            return spoonName
        }
    }
    
    private func getTooltipMessage() -> String {
        if isSelected, let spoonResponse = spoonDrawResponse {
            let spoonName = getSpoonDisplayName(spoonResponse.spoonType.spoonName)
            
            if isToday() {
                return "오늘 \(spoonResponse.spoonType.spoonAmount)개 획득"
            } else {
                return "\(spoonResponse.spoonType.spoonAmount)개 획득"
            }
        } else {
            return "출석하고 스푼받기!"
        }
    }
    
    private func isToday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let koreanWeekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let weekdayIndex = calendar.component(.weekday, from: today) - 1
        let todayWeekday = koreanWeekdays[weekdayIndex]
        
        return day == todayWeekday
    }
}

#Preview {
    VStack(spacing: 20) {
        SpoonAttendanceView(
            day: "월",
            isSelected: false,
            action: {}
        )
        
        SpoonAttendanceView(
            day: "화",
            isSelected: true,
            spoonDrawResponse: SpoonDrawResponse(
                drawId: 1,
                spoonType: SpoonType(
                    spoonTypeId: 4,
                    spoonName: "diamond",
                    spoonAmount: 4,
                    probability: 10.0,
                    spoonImage: "https://spoony-storage.s3.ap-northeast-2.amazonaws.com/spoon/spoon_dia.png"
                ),
                localDate: "2025-06-04",
                weekStartDate: "2025-06-02",
                createdAt: "2025-06-04T13:59:49.330686"
            ),
            action: {}
        )
    }
    .padding()
}
