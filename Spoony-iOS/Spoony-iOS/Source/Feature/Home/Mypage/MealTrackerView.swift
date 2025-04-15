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
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .attendanceCheck,
                spoonCount: 11,
                onBackTapped: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            VStack(alignment: .leading, spacing: 20) {
                Text("매일 출석하고\n오늘의 스푼을 획득하세요")
                    .font(.title1)
                    .lineLimit(2)
                    .padding(.top, 20)
              
                Text(dateRange)
                    .font(.body2m)
                    .foregroundColor(.gray)
                    .padding(.top, -8)
                
                
                // 획득 개수 메시지 추가
                if !selectedDays.isEmpty {
                    Text("오늘 \(selectedDays.count)개 획득")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.black)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                // Info section
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
                
                // 하단 인디케이터 추가
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
    
    // 요일 토글 함수 추가
    private func toggleDay(_ day: String) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

// Bullet point text component
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
