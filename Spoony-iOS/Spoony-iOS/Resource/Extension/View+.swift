//
//  View+.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI

extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
    
    func popup(popup: PopupType, isPresented: Binding<Bool>, action: @escaping () -> Void) -> some View {
        modifier(PopupModifier(popup: popup, isPresented: isPresented, confirmAction: action))
    }
    
    // TextField placeholder를 위한 extension
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    //홈 바텀시트 코너 radius
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
