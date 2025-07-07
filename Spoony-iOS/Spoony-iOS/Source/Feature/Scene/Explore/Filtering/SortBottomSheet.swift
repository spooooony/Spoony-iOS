//
//  SortBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/14/25.
//

import SwiftUI

enum SortType: String, CaseIterable {
    case createdAt = "latest"
    case zzimCount = "most_saved"
    
    var title: String {
        switch self {
        case .createdAt:
            "최신순"
        case .zzimCount:
            "저장 많은 순"
        }
    }
}

struct SortBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedSort: SortType
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(SortType.allCases, id: \.self) { type in
                SpoonyButton(
                    style: selectedSort == type ? .activate : .deactivate,
                    size: .xlarge,
                    title: type.title,
                    disabled: .constant(false)
                ) {
                    selectedSort = type
                    isPresented = false
                }
            }
            SpoonyButton(
                style: .secondary,
                size: .xlarge,
                title: "취소",
                disabled: .constant(false)
            ) {
                isPresented = false
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 22.adjustedH)
    }
}
