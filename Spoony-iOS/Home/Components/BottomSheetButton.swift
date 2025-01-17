import SwiftUI

struct BottomSheetButton: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        CustomBottomSheet(style: .button, isPresented: $isPresented) {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text("텍스트")
                    .font(.system(size: 16))
                
                Button(action: {
                    isPresented = false
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