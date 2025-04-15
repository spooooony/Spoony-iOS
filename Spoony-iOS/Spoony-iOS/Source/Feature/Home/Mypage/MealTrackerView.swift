//
//  MealTrackerView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/15/25.
//

import SwiftUI

struct MealTrackerView: View {
    @State private var selectedDays = Set<String>(["월", "화"])
    @Environment(\.presentationMode) var presentationMode
    let dateRange = "2025. 03. 24 (월) ~ 2025. 03. 30 (일)"
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer()
                Color.gray0
                    .ignoresSafeArea()
                    .frame(height: 168.adjustedH)
            }
            .ignoresSafeArea()
            
            // 메인 콘텐츠
            VStack(spacing: 0) {
                CustomNavigationBar(style: .attendanceCheck,
                                   title: "출석체크")
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("매일 출석하고\n오늘의 스푼을 획득하세요")
                            .font(.title1)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                        
                        Image(systemName: "info.circle")
                            
                            .foregroundColor(.gray)
                        
                    }
                        Text(dateRange)
                            .font(.body2m)
                            .foregroundColor(.gray)
                    
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]

                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(weekdays, id: \.self) { day in
                            SpoonAttendanceView(
                                day: day,
                                isSelected: selectedDays.contains(day),
                                action: { toggleDay(day) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Spacer().frame(height: 36)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("유의사항")
                            .font(.body2b)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPointText(text: "출석체크는 매일 자정에 리셋 되어요")
                            BulletPointText(text: "1일 1회 무료로 참여 가능해요")
                            BulletPointText(text: "신규 가입 시 5개의 스푼을 적립해 드려요")
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // 요일 토글 함수
    private func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

// 불릿 포인트 텍스트 컴포넌트
struct BulletPointText: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body2sb)
                .foregroundColor(.gray400)
            
            Text(text)
                .font(.body2sb)
                .foregroundColor(.gray400)
        }
    }
}

#Preview {
    MealTrackerView()
}
