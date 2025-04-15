//
//  SwiftUIView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/15/25.
//

import SwiftUI

struct MealTrackerView: View {
    @State private var selectedDays = Set<String>(["월", "화"])
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    let dateRange = "2025. 03. 24 (월) ~ 2025. 03. 30 (일)"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with title and notification count
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("출석체크")
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 36, height: 36)
                        
                        Text("11")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .offset(x: 8, y: 0)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                // Main content
                VStack(alignment: .leading, spacing: 16) {
                    Text("매일 출석하고\n오늘의 스푼을 획득하세요")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.top, 20)
                    
                    HStack {
                        Text("ⓘ")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        
                        Slider(value: .constant(1.0))
                            .disabled(true)
                    }
                    
                    Text(dateRange)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, -8)
                    
                    // Days of week with spoons
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(weekdays, id: \.self) { day in
                            DaySpoonView(
                                day: day,
                                isSelected: selectedDays.contains(day)
                            )
                        }
                    }
                    .padding(.top, 8)
                    
                    if selectedDays.count == 2 {
                        Text("오늘 2개 획득")
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
                    
                    // Bottom indicator
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 50, height: 4)
                        .cornerRadius(2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

// Day with spoon component
struct DaySpoonView: View {
    let day: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(height: 110)
            
            VStack {
                Text(day)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .red : .gray)
                    .padding(.top, 8)
                
                Image(systemName: "spoon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 45)
                    .foregroundColor(isSelected ? Color.brown : Color.gray.opacity(0.5))
                    .padding(.top, 5)
            }
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

// Preview
struct MealTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MealTrackerView()
    }
}
