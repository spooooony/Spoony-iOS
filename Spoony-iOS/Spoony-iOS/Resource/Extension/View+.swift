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
    
    func alertView(alertType: Binding<AlertType?>, alert: Alert?, confirmAction: (() -> Void)?) -> some View {
        self.modifier(AlertModifier(alertType: alertType, alert: alert, confirmAction: confirmAction))
    }
    
    func popup(popup: Binding<PopupType?>, confirmAction: @escaping ((PopupType) -> Void)) -> some View {
        modifier(PopupModifier(popup: popup, confirmAction: confirmAction))
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
    
    //홈 PlaceCard 코너 radius
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // 화면 터치시 키보드를 내리기 위한 extension
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func customFont(_ font: Font) -> some View {
        self.modifier(CustomFontModifier(font: font))
    }
    
    // 조건부로 hidden()을 사용하기 위한 extension
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }

    func spoonyShadow(style: ShadowStyle) -> some View {
        self.modifier(ShadowModifier(style: style))
    }
}
