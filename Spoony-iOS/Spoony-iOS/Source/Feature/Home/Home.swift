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
    @State private var showDetailWithChipView = false
    @State private var showTextInputView = false
    
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
                
                Button("상세 화면으로 (타이틀)") {
                    showDetailView = true
                }
                
                Button("상세 화면으로 (칩)") {
                    showDetailWithChipView = true
                }
                
                Button("지도 화면으로") {
                    showTextInputView = true
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
            .navigationDestination(isPresented: $showDetailWithChipView) {
                DetailView(showTitle: false)
            }
            .navigationDestination(isPresented: $showTextInputView) {
                TextInputView()
            }
        }
    }
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .search(showBackButton: true),
                searchText: $searchText,
                onBackTapped: { dismiss() }
            )
            
            ScrollView {
            }
        }
        .navigationBarHidden(true)
    }
}

struct LocationView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .locationDetail,
                title: "서울특별시 마포구",
                onBackTapped: {
                    dismiss()
                }
            )
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
}

struct TextInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .locationTitle,
                title: "홍대입구역",
                onBackTapped: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    Text("지도 화면 컨텐츠")
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked: Bool = false
    var showTitle: Bool = true
    
    init(showTitle: Bool = true) {
        self.showTitle = showTitle
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showTitle {
                CustomNavigationBar(
                    style: .detail(isLiked: isLiked),
                    title: "상세 정보",
                    onBackTapped: {
                        dismiss()
                    },
                    onLikeTapped: {
                        isLiked.toggle()
                    }
                )
            } else {
                CustomNavigationBar(
                    style: .detailWithChip(count: 99),
                    onBackTapped: {
                        dismiss()
                    }
                )
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    Text(showTitle ? "타이틀이 있는 상세 화면" : "칩이 있는 상세 화면")
                        .padding()
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

