//
//  DropDownMenu.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/16/25.
//

import SwiftUI

public struct DropDownMenu: View {
    private var items: [String]
    @Binding private var isPresented: Bool
    private var action: (String) -> Void
    
    public init(
        items: [String],
        isPresented: Binding<Bool>,
        action: @escaping (String) -> Void
    ) {
        self.items = items
        self._isPresented = isPresented
        self.action = action
    }
    
    public var body: some View {
        if isPresented {
            VStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    Button(action: {
                        action(item)
                        isPresented = false
                    }) {
                        HStack {
                            Text(item)
                                .customFont(.caption1b)
                                .foregroundColor(.gray900)
                                .padding(.vertical, 16.adjustedH)
                                .padding(.leading, 14.adjustedH)
                            
                            Spacer()
                        }
                    }
                    .frame(width: 107.adjusted, height: 49.adjustedH, alignment: .leading)
                }
            }
            .background(.white)
            .cornerRadius(10)
            .shadow(color: Color(red: 0.76, green: 0.77, blue: 0.78), radius: 8, x: 1, y: 1)
        }
    }
}

#Preview {
    DropDownMenu(
        items: ["수정하기", "신고하기"],
        isPresented: .constant(true)
    ) { print($0) }
}
