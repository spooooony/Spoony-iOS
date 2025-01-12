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
                CustomBottomSheet(style: .half, isPresented: $showListSheet) {
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
            
            if showButtonSheet {
                CustomBottomSheet(style: .button, isPresented: $showButtonSheet) {
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Text("텍스트")
                            .font(.system(size: 16))
                        
                        Button(action: {
                            showButtonSheet = false
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
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    Home()
        .environmentObject(NavigationManager())
}
