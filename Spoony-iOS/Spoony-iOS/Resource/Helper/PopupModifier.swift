//
//  PopupModifier.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/12/25.
//

import SwiftUI

import Lottie

struct PopupModifier: ViewModifier {
    @Binding var popup: PopupType?
    let confirmAction: (PopupType) -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if let popup = popup {
                Color.black.opacity(0.6)
                    .ignoresSafeArea(.all)
                
                PopupView(popup: $popup) {
                    confirmAction(popup)
                }
            }
        }
    }
}

enum PopupType: Equatable {
    case useSpoon
    case reportSuccess
    case registerSuccess
    case delete
}

struct PopupView: View {
    @Binding var popup: PopupType?
    let confirmAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)
            
            if let animationString {
                Group {
                    if isLooping {
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
                .customFont(.body1b)
                .padding(.bottom, descriptionYOffset)
            
            HStack(spacing: 12) {
                if let title = grayButtonTitle {
                    SpoonyButton(
                        style: .teritary,
                        size: .xsmall,
                        title: title,
                        disabled: .constant(false)
                    ) {
                        popup = nil
                    }
                }
                SpoonyButton(
                    style: buttonStyle,
                    size: grayButtonTitle == nil ? .large : .xsmall,
                    title: blackButtonTitle,
                    disabled: .constant(false)
                ) {
                    confirmAction()
                    popup = nil
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
            return "lottie_popup_get"
        case .registerSuccess:
            return "lottie_popup_get"
        case .reportSuccess, .delete, .none:
            return nil
        }
    }
    
    private var description: String {
        switch popup {
        case .useSpoon:
            "스푼 1개를 사용하여 확인해 볼까요?"
        case .registerSuccess:
            "리뷰를 등록했어요!\n이제 새로운 장소를 떠먹으러 가볼까요?"
        case .reportSuccess:
            "신고가 접수되었어요"
        case .delete:
            "정말로 리뷰를 삭제할까요?"
        case .none:
            ""
        }
    }
    
    private var blackButtonTitle: String {
        switch popup {
        case .useSpoon:
            "확인할래요"
        case .registerSuccess:
            "좋아요!"
        case .reportSuccess:
            "확인"
        case .delete:
            "네" // ✅
        case .none:
            ""
        }
    }
    
    private var grayButtonTitle: String? {
        switch popup {
        case .useSpoon, .delete:
            "아니요"
        case .registerSuccess, .reportSuccess, .none:
            nil
        }
    }
    
    private var descriptionYOffset: CGFloat {
        switch popup {
        case .useSpoon, .registerSuccess, .none:
            0
        case .reportSuccess, .delete:
            12
        }
    }
    
    private var isLooping: Bool {
        switch popup {
        case .useSpoon:
            true
        case .reportSuccess, .registerSuccess, .delete, .none:
            false
        }
    }
    
    private var buttonStyle: SpoonyButtonStyle {
        switch popup {
        case .registerSuccess:
                .primary
        case .useSpoon, .reportSuccess, .delete, .none:
                .secondary
        }
    }
    
}
