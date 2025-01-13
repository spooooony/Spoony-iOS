//
//  CustomSearchBar.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.gray600))
                .frame(width: 24)
            
            TextField("", text: $text)
                .frame(height: 44)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(Color(.gray600))
                }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.gray600))
                        .frame(width: 24)
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.gray600), lineWidth: 1)
        )
        .frame(height: 44)
    }
} 