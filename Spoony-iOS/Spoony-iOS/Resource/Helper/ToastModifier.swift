//
//  ToastModifier.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/10/25.
//

import Foundation
import SwiftUI

public struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 2.5
    var width: Double = .infinity
    var yOffset: CGFloat = 638
}

public enum ToastStyle {
    case gray
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .gray: return .gray600
        }
    }
}

struct ToastView: View {
    
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(message)
                .foregroundStyle(.white)
                .font(.body2m)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
        }
        .frame(minWidth: 0, maxWidth: width)
        .background(style.themeColor)
        .cornerRadius(10)
        .opacity(0.9)
        .padding(.horizontal, 20.adjusted)
    }
}

struct ToastModifier: ViewModifier {
    
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast, initial: false) {
                showToast()
            }
    }
    
    @ViewBuilder
    func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer().frame(height: toast.yOffset)
                ToastView(
                    style: toast.style,
                    message: toast.message,
                    width: toast.width
                ) {
                    dismissToast()
                }
            }
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}
