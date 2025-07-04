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
    @Binding var isPresented: Bool
    let alertType: AlertType
    let alert: Alert
    let confirmAction: (() -> Void)?
    let afterAction: (() -> Void)?
    
    @State private var isOpacityZero: Bool = false
    
    func body(content: Content) -> some View {
        
        content
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    Color.black.opacity(isOpacityZero ? 0 : 0.6)
                        .ignoresSafeArea(.all)
                    
                    AlertView(
//                        isPresented: $isPresented,
                        isOpacityZero: $isOpacityZero,
                        alertType: alertType,
                        alert: alert,
                        confirmAction: confirmAction,
                        afterAction: afterAction
                    )
                    .opacity(isOpacityZero ? 0 : 1)
                }
                .background(BackgroundClearView())
                .onAppear {
                    isOpacityZero = false
                }
                .onChange(of: isOpacityZero) {
                    if isOpacityZero {
                        isPresented = false
                    }
                }
            }
            .transaction {
                $0.disablesAnimations = true
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

struct Alert: Equatable {
    let title: String
    let confirmButtonTitle: String
    let cancelButtonTitle: String?
    let imageString: String?
}

struct AlertView: View {
    @Binding var isOpacityZero: Bool
    let alertType: AlertType
    let alert: Alert
    let confirmAction: (() -> Void)?
    let afterAction: (() -> Void)?
    
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
                        isOpacityZero = true
//                        isPresented = false
                    }
                }
                
                SpoonyButton(
                    style: .secondary,
                    size: alert.cancelButtonTitle == nil ? .large : .xsmall,
                    title: alert.confirmButtonTitle,
                    disabled: .constant(false)
                ) {
                    if let confirmAction {
                        confirmAction()
                    }
//                    isPresented = false
                    isOpacityZero = true
                    if let afterAction {
                        afterAction()
                    }
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .transaction {
            $0.disablesAnimations = true
        }
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
