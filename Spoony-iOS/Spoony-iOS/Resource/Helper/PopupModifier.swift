//
//  PopupModifier.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/12/25.
//

import SwiftUI

struct PopupModifier: ViewModifier {
    let popup: PopupType
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    
                PopupView(popup: popup, isPresented: $isPresented)
            }
        }
    }
}

enum PopupType {
    case useSpoon(action: () -> Void)
    case reportSuccess(action: () -> Void)
    case registerSuccess(action: () -> Void)
}

struct PopupView: View {
    let popup: PopupType
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 20)
            if let image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
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
                    
                    SpoonyButton(
                        style: .secondary,
                        size: .xsmall,
                        title: blackButtonTitle,
                        disabled: .constant(false)
                    ) {
                        confirmAction()
                        isPresented = false
                    }
                } else {
                    SpoonyButton(
                        style: .secondary,
                        size: .large,
                        title: blackButtonTitle,
                        disabled: .constant(false)
                    ) {
                        confirmAction()
                        isPresented = false
                    }
                }
            }
        }
        .padding(20)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}

extension PopupView {
    // 임시
    private var image: ImageResource? {
        switch popup {
        case .useSpoon:
            return .icBarBlue
        case .registerSuccess:
            return .icAmericanBlue
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
            "갈래요!"
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
    
    private var confirmAction: () -> Void {
        switch popup {
        case .useSpoon(let action):
            action
        case .registerSuccess(let action):
            action
        case .reportSuccess(let action):
            action
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
    PopupView(popup: .useSpoon(action: {}), isPresented: .constant(true))
}
