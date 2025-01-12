//
//  BottomSheetListItem.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct BottomSheetListItem: View {
    let title: String
    let subtitle: String
    let product: String
    let hasChip: Bool
    
    var body: some View {
        HStack {
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
                            .foregroundColor(.red)
                            .cornerRadius(12)
                    }
                }
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(product)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 60, height: 60)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct BottomSheetList: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        CustomBottomSheet(style: .half, isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 0) {
                Text("타이틀")
                    .font(.system(size: 18, weight: .bold))
                    .padding()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(0..<5) { _ in
                            BottomSheetListItem(
                                title: "상품명",
                                subtitle: "주소",
                                product: "제품",
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
