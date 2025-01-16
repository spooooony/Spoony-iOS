//
//  SpoonyTextField.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/14/25.
//

import SwiftUI

/// SpoonyTextField
/// - Parameters:
///   - placeholder: 플레이스 홀더 메시지
///   - style: 텍스트 필드 스타일
///   - action: 우측 아이콘 버튼 액션
public struct SpoonyTextField: View {
    
    // MARK: - Properties
    @State private var errorState: TextFieldErrorState = .initial
    @FocusState private var isFocused
    @Binding var text: String
    @Binding var isError: Bool
    
    private let placeholder: String
    private let style: SpoonyTextFieldStyle
    var action: (() -> Void)?
    
    // MARK: - Init
    public init(
        text: Binding<String>,
        style: SpoonyTextFieldStyle,
        placeholder: String,
        isError: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self._text = text
        self.style = style
        self.placeholder = placeholder
        self._isError = isError
        self.action = action
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            customTextField
            
            if let message = errorState.errorMessage, isErrorMessageVisible() {
                errorMessageView(message)
            }
        }
    }
}

extension SpoonyTextField {
    
    // MARK: - customTextField
    private var customTextField: some View {
        let borderColor: Color = {
            if errorState != .noError, style == .helper {
                return .error400
            } else if isFocused, style.isBorder {
                return .main400
            } else {
                return .gray100
            }
        }()
        
        return HStack(spacing: 8) {
            if let icon = style.leadingIcon {
                Image(icon)
                    .resizable()
                    .frame(width: 20.adjusted, height: 20.adjusted)
            }
            
            TextField(text: $text) {
                Text(placeholder)
                    .font(.body2m)
                    .foregroundStyle(.gray500)
            }
            .autocapitalization(.none) 
            .autocorrectionDisabled()
            .focused($isFocused)
            .font(.body2m)
            .foregroundStyle(.gray900)
            .onChange(of: text) { oldValue, newValue in
                if style != .icon {
                    switch checkInputError(newValue) {
                    case .maximumInputError:
                        errorState = .maximumInputError
                        text = String(newValue.prefix(30))
                    case .minimumInputError:
                        errorState = .minimumInputError
                    case .invalidInputError:
                        text = oldValue
                    case .noError, .initial:
                        errorState = .noError
                    }
                }
            }
            .onChange(of: isFocused) { _, newValue in
                if !newValue, errorState == .maximumInputError {
                    errorState = .noError
                }
            }
            .onChange(of: errorState) { 
                switch errorState {
                case .noError:
                    isError = false
                default:
                    isError = true
                }
            }
            
            if style.isTrailingItem {
                switch style {
                case .normal:
                    Button {
                        if let action = action {
                            action()
                        }
                    } label: {
                        if let icon = style.trailingIcon,
                           let size = style.iconSize {
                            Image(icon)
                                .resizable()
                                .frame(width: size, height: size)
                        }
                    }
                case .icon:
                    if !text.isEmpty {
                        Button {
                            if let action = action {
                                action()
                            }
                        } label: {
                            if let icon = style.trailingIcon,
                               let size = style.iconSize {
                                Image(icon)
                                    .resizable()
                                    .frame(width: size, height: size)
                            }
                        }
                    }
                case .helper:
                    Text("\(text.count) / 30")
                        .font(.caption1m)
                        .foregroundStyle(errorState != .noError ? .error400 : .gray500)
                }
            }
        }
        .padding(.horizontal, style.interSpacing)
        .frame(width: 335.adjusted, height: 44.adjustedH)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }
    
    // MARK: - errorMessageView
    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: 6) {
            Image(.icErrorRed)
                .resizable()
                .frame(width: 16.adjusted, height: 16.adjustedH)
            
            Text("\(message)")
                .font(.caption1m)
                .foregroundStyle(.error400)
        }
        .padding(.top, 8)
    }
}

// MARK: - Functions
extension SpoonyTextField {
    private func checkInputError(_ input: String) -> TextFieldErrorState {
        let trimmedText = text.replacingOccurrences(of: " ", with: "")
        let regex = "^[a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣\\x20\\p{P}]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if !predicate.evaluate(with: input) {
            return .invalidInputError
        }
        
        if trimmedText.isEmpty {
            return .minimumInputError
        }
        
        if input.count > 30 || (input.count == 30 && errorState == .maximumInputError) {
            return .maximumInputError
        }
        
        return .noError
    }
    
    private func isErrorMessageVisible() -> Bool {
        guard errorState != .noError, style == .helper else {
            return false
        }
        return (errorState == .maximumInputError && isFocused) || errorState == .minimumInputError
    }
}

// MARK: - SpoonyTextFieldStyle
public enum SpoonyTextFieldStyle: Equatable {
    case normal(isIcon: Bool)
    case icon
    case helper
    
    var iconSize: CGFloat? {
        switch self {
        case .normal:
            return 24.adjusted
        case .icon:
            return 20.adjusted
        case .helper:
            return nil
        }
    }
    
    var interSpacing: CGFloat {
        switch self {
        case .normal, .helper:
            return 12
        case .icon:
            return 16
        }
    }
    
    var leadingIcon: String? {
        switch self {
        case .normal, .helper:
            return nil
        case .icon:
            return "ic_search_gray600"
        }
    }
    
    var trailingIcon: String? {
        switch self {
        case .normal:
            return "ic_minus_gray400"
        case .icon:
            return "ic_delete_fill_gray400"
        case .helper:
            return nil
        }
    }
    
    var isBorder: Bool {
        switch self {
        case .normal, .helper:
            return true
        case .icon:
            return false
        }
    }
    
    var isTrailingItem: Bool {
        switch self {
        case .normal(let isIcon):
            return isIcon
        case .icon, .helper:
            return true
        }
    }
}

// MARK: - TextFieldErrorState
public enum TextFieldErrorState {
    case maximumInputError
    case minimumInputError
    case invalidInputError
    case noError
    case initial
    
    var errorMessage: String? {
        switch self {
        case .maximumInputError:
            return "글자 수 30자 이하로 입력해 주세요"
        case .minimumInputError:
            return "한 줄 소개는 필수예요"
        case .noError, .invalidInputError, .initial:
            return nil
        }
    }
}
