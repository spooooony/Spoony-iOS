//
//  Home.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var showSearchView = false
    @State private var showLocationView = false
    @State private var showDetailView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Spoony")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("검색 화면으로") {
                    showSearchView = true
                }
                
                Button("위치 선택 화면으로") {
                    showLocationView = true
                }
                
                Button("상세 화면으로") {
                    showDetailView = true
                }
            }
            .padding()
            .navigationDestination(isPresented: $showSearchView) {
                SearchView()
            }
            .navigationDestination(isPresented: $showLocationView) {
                LocationView()
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailView()
            }
        }
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image("ic_arrow_left_gray700")
                        .frame(width: 24, height: 24)
                }
                
                CustomSearchBar(
                    text: $searchText,
                    placeholder: "플레이스 홀더",
                    onSubmit: {
                        // 검색 로직
                    }
                )
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color.white)
            
            ScrollView {
                // 검색 결과 컨텐츠
            }
        }
    }
}

struct LocationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .location,
                title: "서울특별시 마포구",
                onBackTapped: {
                    dismiss()
                }
            )
            
            // 위치 선택 화면 컨텐츠
        }
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .primary,
                title: "상세 정보",
                onBackTapped: {
                    dismiss()
                }
            )
            
            // 상세 화면 컨텐츠
        }
    }
}

            // 상세 화면 컨텐츠
