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
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Image("bg_bottom_grad")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                    
                    HStack(spacing: 8) {
                            
                            Image("VSpoon")
                            .frame(width: 100.adjusted, height: 100.adjustedH)
                         
                        VStack(alignment: .leading, spacing: 8.adjusted) {
                            Text("오늘의 스푼 받기")
                                .customFont(.title2)
                                .foregroundColor(.white)
                            
                            Text("매일 출석하면 오늘의 스푼을 받을 수 있어요.\n스푼은 비공개 리뷰를 확인할 수 있는 재화예요.")
                                .customFont(.body2m)
                                .foregroundColor(.gray400)
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 2) {
                    StampCategoryRow(title: "일회용 티스푼", count: "1개 적립")
                    StampCategoryRow(title: "일회용 티스푼", count: "1개 적립")
                    StampCategoryRow(title: "일회용 티스푼", count: "1개 적립")
                    StampCategoryRow(title: "일회용 티스푼", count: "1개 적립")
                }
                .background(Color.white)
                .padding(.top, 24)
                .padding(.bottom, 56)
                
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .ignoresSafeArea(edges: .bottom)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(.icCloseWhite)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .presentationDetents([.height(900)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    AttendanceInfoSheetView()
}
