//
//  BottomSheetList.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct BottomSheetListItem: View {
    let title: String
    let subtitle: String
    let cellTitle: String
    let hasChip: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                    if hasChip {
                        Text("chip")
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(Color.red)
                            .cornerRadius(12)
                    }
                }
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(cellTitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer(minLength: 10)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 98, height: 98)
        }
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
    }
}

struct BottomSheetList: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        CustomBottomSheet(style: .half, isPresented: $isPresented) {
            VStack(alignment: .center, spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<5) { _ in
                            BottomSheetListItem(
                                title: "상호명",
                                subtitle: "주소",
                                cellTitle: "제목 셀",
                                hasChip: true
                            )
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
