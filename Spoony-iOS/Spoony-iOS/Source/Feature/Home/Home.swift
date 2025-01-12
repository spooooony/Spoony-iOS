//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
struct Home: View {
    
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var showListSheet = false
    @State private var showButtonSheet = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("SpoonMe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button(action: {
                    showListSheet = true
                }) {
                    Text("리스트형 바텀시트 보기")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    showButtonSheet = true
                }) {
                    Text("버튼형 바텀시트 보기")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 15) {
                    ForEach(1...3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("메뉴 \(index)")
                            )
                    }
                }
            }
            .padding()
            
            if showListSheet {
                BottomSheetList(isPresented: $showListSheet)
            }
            
            if showButtonSheet {
                BottomSheetButton(isPresented: $showButtonSheet)
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}
