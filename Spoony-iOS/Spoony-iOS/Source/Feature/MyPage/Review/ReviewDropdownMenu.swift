//
//  ReviewDropdownMenu.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 5/5/25.
//

import SwiftUI

struct ReviewDropdownMenu: View {
    @Binding var isShowing: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                onEdit()
                isShowing = false
            }) {
                HStack {
                    Text("수정하기")
                        .customFont(.caption1b)
                        .foregroundColor(.spoonBlack)
                    Spacer()
                }
                .frame(height: 44.adjustedH)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
            
            Button(action: {
                onDelete()
                isShowing = false
            }) {
                HStack {
                    Text("삭제하기")
                        .customFont(.caption1b)
                        .foregroundColor(.spoonBlack)
                    Spacer()
                }
                .frame(height: 44.adjustedH)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
        }
        .frame(width: 107.adjusted)
        .cornerRadius(10)
        .modifier(ShadowModifier(style: .shadow300))

    }
}

extension View {
    func reviewDropdownMenu(
        isShowing: Binding<Bool>,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        self.overlay(
            ZStack(alignment: .topTrailing) {
                if isShowing.wrappedValue {
                    Color.black.opacity(0.01)
                        .onTapGesture {
                            isShowing.wrappedValue = false
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    ReviewDropdownMenu(
                        isShowing: isShowing,
                        onEdit: onEdit,
                        onDelete: onDelete
                    )
                    .padding(.trailing, 50)
                    .padding(.top, 30)
                }
            },
            alignment: .topTrailing
        )
    }
}

#Preview {
    ReviewDropdownMenu(
        isShowing: .constant(true),
        onEdit: {},
        onDelete: {}
    )
}
