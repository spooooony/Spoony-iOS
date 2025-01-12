//
//  BottomSheetButton.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct BottomSheetButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        CustomBottomSheet(style: .half, isPresented: $isPresented) {
            VStack(alignment: .leading, spacing: 0) {
                Text("타이틀")
                    .font(.system(size: 18, weight: .bold))
                    .padding()
                
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Text("텍스트")
                        .font(.system(size: 16))
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("버튼")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }
}
#Preview {
    BottomSheetButton(isPresented: .constant(true))
}
