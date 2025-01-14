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
}
