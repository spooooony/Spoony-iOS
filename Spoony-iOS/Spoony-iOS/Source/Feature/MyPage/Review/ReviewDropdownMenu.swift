import SwiftUI

struct ReviewDropdownMenu: View {
    @Binding var isShowing: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                onEdit()
                isShowing = false
            }) {
                HStack {
                    Text("수정하기")
                        .customFont(.body2m)
                        .foregroundColor(.spoonBlack)
                    Spacer()
                }
                .frame(height: 48)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
            
            Divider()
                .foregroundColor(.gray100)
            
            Button(action: {
                onDelete()
                isShowing = false
            }) {
                HStack {
                    Text("삭제하기")
                        .customFont(.body2m)
                        .foregroundColor(.spoonBlack)
                    Spacer()
                }
                .frame(height: 48)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
        }
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .offset(x: -10, y: 10)
        .zIndex(100)
        .transition(.opacity)
    }
}

extension View {
    func reviewDropdownMenu(
        isShowing: Binding<Bool>,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {
        self.overlay(
            ZStack(alignment: .topTrailing) {
                if isShowing.wrappedValue {
                    Color.black.opacity(0.01)
                        .onTapGesture {
                            isShowing.wrappedValue = false
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    ReviewDropdownMenu(
                        isShowing: isShowing,
                        onEdit: onEdit,
                        onDelete: onDelete
                    )
                }
            },
            alignment: .topTrailing
        )
    }
}