//
//  PopupModifier.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/12/25.
//

import SwiftUI

import Lottie

struct PopupModifier: ViewModifier {
    let popup: PopupType
    @Binding var isPresented: Bool
    let confirmAction: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea(.all)
                
                PopupView(popup: popup, isPresented: $isPresented) {
                    confirmAction()
                }
            }
        }
    }
}

enum PopupType {
    case useSpoon
    case reportSuccess
    case registerSuccess
}

struct PopupView: View {
    let popup: PopupType
    @Binding var isPresented: Bool
    let confirmAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)
            
            if let animationString {
                Group {
                    if popup == .useSpoon {
                        LottieView(animation: .named(animationString))
                            .looping()
                    } else {
                        LottieView(animation: .named(animationString))
                            .playing()
                    }
                }
                .frame(width: 250.adjusted, height: 150.adjustedH)
                .padding(.top, -20)
            }
            
            Text(description)
                .multilineTextAlignment(.center)
                .font(.body1b)
                .padding(.bottom, descriptionYOffset)
            
            HStack(spacing: 12) {
                if let title = grayButtonTitle {
                    SpoonyButton(
                        style: .teritary,
                        size: .xsmall,
                        title: title,
                        disabled: .constant(false)
                    ) {
                        isPresented = false
                    }
                }
                SpoonyButton(
                    style: popup == .registerSuccess ? .primary : .secondary,
                    size: grayButtonTitle == nil ? .large : .xsmall,
                    title: blackButtonTitle,
                    disabled: .constant(false)
                ) {
                    confirmAction()
                    isPresented = false
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

extension PopupView {
    private var animationString: String? {
        switch popup {
        case .useSpoon:
            return "lottie_popup_use"
        case .registerSuccess:
            return "lottie_popup_get"
        case .reportSuccess:
            return nil
        }
    }
    
    private var description: String {
        switch popup {
        case .useSpoon:
            "수저 1개를 사용하여 떠먹어 볼까요?"
        case .registerSuccess:
            "수저 1개를 획득했어요!\n이제 새로운 장소를 떠먹으러 가볼까요?"
        case .reportSuccess:
            "신고가 접수되었어요"
        }
    }
    
    private var blackButtonTitle: String {
        switch popup {
        case .useSpoon:
            "떠먹을래요"
        case .registerSuccess:
            "좋아요!"
        case .reportSuccess:
            "확인"
        }
    }
    
    private var grayButtonTitle: String? {
        switch popup {
        case .useSpoon:
            "아니요"
        case .registerSuccess, .reportSuccess:
            nil
        }
    }
    
    private var descriptionYOffset: CGFloat {
        switch popup {
        case .useSpoon, .registerSuccess:
            0
        case .reportSuccess:
            12
        }
    }
    
}

#Preview {
    PopupView(popup: .useSpoon, isPresented: .constant(true)) {
        print("dd")
    }
}
