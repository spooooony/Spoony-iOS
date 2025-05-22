//
//  AlertModifier.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/19/25.
//

// TODO: popup modifier랑 합치기

import SwiftUI

import Lottie

struct AlertModifier: ViewModifier {
    @Binding var alertType: AlertType?
    let alert: Alert?
    let confirmAction: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if alertType != nil,
               alert != nil,
               confirmAction != nil {
                Color.black.opacity(0.6)
                    .ignoresSafeArea(.all)
                
                AlertView(
                    alertType: $alertType,
                    alert: alert!
                ) {
                    confirmAction!()
                }
            }
        }
    }
}

enum AlertType: Equatable {
    case normalButtonOne
    case normalButtonTwo
    // Popup에 있는 애들
    case imageButtonOne
    case imageButtonTwo
}

enum AlertAction: Equatable {
    case reportSuccess
    case block
}

struct Alert: Equatable {
    let title: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String?
    let imageString: String?
}

struct AlertView: View {
    @Binding var alertType: AlertType?
    let alert: Alert
    let confirmAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)
            
            if let image = alert.imageString {
                LottieView(animation: .named(image))
                    .looping()
                    .frame(width: 250.adjusted, height: 150.adjustedH)
                    .padding(.top, -20)
            }
            
            Text(alert.title)
                .multilineTextAlignment(.center)
                .customFont(.body1b)
                .padding(
                    .bottom,
                    alertType == .normalButtonOne
                    || alertType == .imageButtonOne ? 32 : 20
                )
            
            HStack(spacing: 12) {
                if let title = alert.cancelButtonTitle {
                    SpoonyButton(
                        style: .teritary,
                        size: .xsmall,
                        title: title,
                        disabled: .constant(false)
                    ) {
                        alertType = nil
                    }
                }
                
                SpoonyButton(
                    style: .secondary,
                    size: alert.cancelButtonTitle == nil ? .large : .xsmall,
                    title: alert.confirmButtonTitle,
                    disabled: .constant(false)
                ) {
                    confirmAction()
                    alertType = nil
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
