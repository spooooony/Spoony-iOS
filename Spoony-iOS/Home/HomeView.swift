import SwiftUI

struct HomeView: View {
    @State private var showFullBottomSheet = false
    @State private var showHalfBottomSheet = false
    @State private var showMinimalBottomSheet = false
    @State private var showButtonBottomSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("전체 크기 바텀시트") {
                showFullBottomSheet.toggle()
            }
            
            Button("중간 크기 바텀시트") {
                showHalfBottomSheet.toggle()
            }
            
            Button("최소 크기 바텀시트") {
                showMinimalBottomSheet.toggle()
            }
            
            Button("버튼 바텀시트") {
                showButtonBottomSheet.toggle()
            }
        }
        .overlay {
            BottomSheetList(isPresented: $showFullBottomSheet, style: .full)
            BottomSheetList(isPresented: $showHalfBottomSheet, style: .half)
            BottomSheetList(isPresented: $showMinimalBottomSheet, style: .minimal)
            BottomSheetButton(isPresented: $showButtonBottomSheet)
        }
    }
} 