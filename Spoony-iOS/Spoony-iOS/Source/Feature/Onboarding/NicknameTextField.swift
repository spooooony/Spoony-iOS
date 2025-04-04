//
//  NicknameTextField.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/2/25.
//

import SwiftUI

struct NicknameTextField: View {
    @State private var errorState: NicknameTextFieldErrorState = .initial
    @Binding var text: String
    @Binding var isError: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            customTextField
            
            helperView
        }
    }
    
    private var customTextField: some View {
        return VStack(alignment: .trailing, spacing: 0) {
            HStack {
                TextField(text: $text) {
                    Text("스푼의 이름을 정해주세요")
                        .customFont(.body2m)
                        .foregroundStyle(.gray400)
                }
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .customFont(.body2m)
                    .lineLimit(1)
                
                Image(.icDeleteFillGray400)
                    .padding(.trailing, -2)
                    .padding(.leading, 8)
                    .opacity(!text.isEmpty ? 1 : 0)
                    .onTapGesture {
                        text = ""
                    }
            }
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(errorState.errorColor, lineWidth: 1)
            }
            .onChange(of: text) { oldValue, newValue in

                if oldValue.removeSpecialCharacter() != oldValue {
                    return
                }

                switch checkInputError(newValue) {
                case .maximumInputError:
                    errorState = .maximumInputError
                    text = String(newValue.prefix(10))
                case .minimumInputError:
                    errorState = .minimumInputError
                case .emojiError:
                    errorState = .emojiError
                    text = newValue.removeSpecialCharacter()
                case .initial, .noError:
                    errorState = .noError
                default:
                    break
                }
            }
            .onChange(of: isFocused) { _, newValue in
                if !newValue,
                    errorState == .maximumInputError || errorState == .emojiError {
                    errorState = .noError
                }
            }
            .onChange(of: errorState) {
                switch errorState {
                case .initial, .noError:
                    isError = false
                default:
                    isError = true
                }
            }
        }
    }
    
    private var helperView: some View {
        HStack(spacing: 6) {
            if let icon = errorState.icon {
                icon
                    .resizable()
                    .frame(width: 16.adjusted, height: 16.adjustedH)
            }
            if let message = errorState.errorMessage {
                Text("\(message)")
                    .customFont(.caption1m)
            }
            
            Spacer()
            
            Text("\(text.count) / 10")
                .customFont(.caption1m)
        }
        .foregroundStyle(errorState.errorColor)
        .padding(.top, 8)
    }
    
    private func checkInputError(_ input: String) -> NicknameTextFieldErrorState {
        
        let removeText = input.removeSpecialCharacter()
        if removeText !=  input {
            return .emojiError
        }
        
        let trimmedText = input.replacingOccurrences(of: " ", with: "")
        if trimmedText.isEmpty {
            return .minimumInputError
        }

        if input.count > 10 || (input.count == 10 && errorState == .maximumInputError) {
            return .maximumInputError
        }
        
        return .noError
    }
}

enum NicknameTextFieldErrorState {
    case duplicateNicknameError
    case minimumInputError
    case maximumInputError
    case emojiError
    case avaliableNickname
    case noError
    case initial
    
    var errorMessage: String? {
        switch self {
        case .duplicateNicknameError:
            return "이미 사용 중인 닉네임이에요"
        case .minimumInputError:
            return "닉네임은 필수예요"
        case .maximumInputError:
            return "10자 이하로 입력해 주세요"
        case .emojiError:
            return "닉네임은 한글, 영문, 숫자만 사용할 수 있어요"
        case .avaliableNickname:
            return "사용 가능한 닉네임이에요"
        case .noError, .initial:
            return nil
        }
    }
    
    var errorColor: Color {
        switch self {
        case .avaliableNickname:
                .green400
        case .noError, .initial:
                .gray100
        default:
                .error400
        }
    }
    
    var icon: Image? {
        switch self {
        case .avaliableNickname:
            Image(.icCheckGreen)
        case .noError, .initial:
            nil
        default:
            Image(.icErrorRed)
        }
    }
}

#Preview {
    NicknameTextField(text: .constant(""), isError: .constant(.random()))
}
