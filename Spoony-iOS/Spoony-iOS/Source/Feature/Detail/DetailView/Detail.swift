//
//  Detail.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Detail: View {
    @State private var isPresented: Bool = false
    
    var body: some View {
        VStack {
            Text("Detail")
                .onTapGesture {
                    isPresented = true
                }
        }
        .sheet(isPresented: $isPresented) {
            FilterBottomSheet(isPresented: $isPresented)
                .presentationDetents([.height(264)])
                .presentationCornerRadius(16)
        }
    }
}

#Preview {
    Detail()
}
