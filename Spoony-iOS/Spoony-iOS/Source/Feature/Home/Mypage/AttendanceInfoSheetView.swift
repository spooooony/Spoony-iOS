//
//  AttendanceInfoSheetView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/17/25.
//

import SwiftUI

struct AttendanceInfoSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("출석체크 안내")
                    .font(.title3b)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.gray400)
                }
            }
            .padding(.top, 16)
            
            // 컨텐츠
            VStack(alignment: .leading, spacing: 16) {
                infoSection(
                    title: "출석체크 혜택",
                    items: [
                        "매일 출석체크 시 스푼 1개가 지급됩니다",
                        "7일 연속 출석 시 추가 스푼 3개를 드려요",
                        "한 달 개근 시 프리미엄 스푼 뱃지를 획득할 수 있어요"
                    ]
                )
                
                Divider()
                
                infoSection(
                    title: "스푼 활용 방법",
                    items: [
                        "스푼으로 프리미엄 맛집 정보를 열람할 수 있어요",
                        "50개 이상 모으면 실물 굿즈로 교환 가능해요",
                        "맛집 리뷰 작성 시 추가 보상을 받을 수 있어요"
                    ]
                )
            }
            .padding(.horizontal, 8)
            
            // 하단 버튼
            Button(action: { dismiss() }) {
                Text("확인했어요")
                    .font(.body1b)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.main400)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
        .background(Color.white)
    }
    
    private func infoSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.body1b)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    BulletPointText(text: item)
                }
            }
        }
    }
}
