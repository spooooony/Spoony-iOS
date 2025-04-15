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
        VStack(spacing: 0) {
            // 커스텀 네비게이션 바
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("출석체크")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("11")
                        .font(.system(size: 16, weight: .bold))
                    
                    Image(systemName: "spoon")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("매일 출석하고\n오늘의 스푼을 획득하세요")
                    .font(.title1)
                    .lineLimit(2)
                
                // 날짜 정보
                HStack {
                    Text(dateRange)
                        .font(.body2m)
                        .foregroundColor(.gray)
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .padding(.top, -8)
                
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

                Spacer()
                
                // 유의사항
                Text("유의사항")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletPointText(text: "출석체크는 매일 자정에 리셋 되어요")
                    BulletPointText(text: "1일 1회 무료로 참여 가능해요")
                    BulletPointText(text: "신규 가입 시 5개의 스푼을 적립해 드려요")
                }
                .padding(.top, 4)
                
                Spacer()
                
                // 하단 인디케이터
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 50, height: 4)
                    .cornerRadius(2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.top)
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
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    MealTrackerView()
}
