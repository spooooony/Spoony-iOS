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
    @State var errorState: TextFieldErrorState = .noError
    @Binding var text: String
    @FocusState private var isFocused
    
    let placeholder: String
    let style: SpoonyTextFieldStyle
    var action: () -> Void
    
    // MARK: - Init
    public init(
        placeholder: String,
        style: SpoonyTextFieldStyle,
        text: Binding<String>,
        action: @escaping () -> Void
    ) {
        self.placeholder = placeholder
        self.style = style
        self._text = text
        self.action = action
    }
        
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customTextField
            
            if errorState != .noError  && style == .count {
                if let message = errorState.errorMessage {
                    HStack(spacing: 6) {
                        Image(.icErrorRed)
                            .resizable()
                            .frame(width: 16.adjusted, height: 16.adjusted)
                        
                        Text("\(message)")
                            .font(.caption1m)
                            .foregroundStyle(.error400)
                    }
                }
            }
        }
    }
}

extension SpoonyTextField {
    
    // MARK: - customTextField
    private var customTextField: some View {
        HStack(spacing: 8) {
            if style.isLeadingIcon {
                if let icon = style.leadingIcon {
                    Image(icon)
                        .resizable()
                        .frame(width: 20.adjusted, height: 20.adjusted)
                }
            }
            
            TextField(text: $text) {
                Text(placeholder)
                    .font(.body2m)
                    .foregroundStyle(.gray500)
            }
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
                    case .noError:
                        errorState = .noError
                    }
                }
            }
            
            if style.isTrailingItem {
                switch style {
                case .normal:
                    Button {
                        action()
                    } label: {
                        if let icon = style.trailingIcon {
                            Image(icon)
                                .resizable()
                                .frame(width: style.iconSize, height: style.iconSize)
                        }
                    }
                case .icon:
                    if isFocused {
                        Button {
                            action()
                        } label: {
                            if let icon = style.trailingIcon {
                                Image(icon)
                                    .resizable()
                                    .frame(width: style.iconSize, height: style.iconSize)
                            }
                        }
                    }
                case .count:
                    Text("\(text.count) / 30")
                        .font(.caption1m)
                        .foregroundStyle(errorState != .noError ? .error400 : .gray500)
                }
            }
        }
        .padding(.horizontal, style.interSpacing)
        .frame(width: 335.adjusted, height: 44.adjusted)
        .focused($isFocused)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused && style.isBorder ? .main400 : .gray100, lineWidth: 1)
        }
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
        } else if input.count > 30 {
            return .maximumInputError
        } else if input.count == 30 && errorState == .maximumInputError {
            return .maximumInputError
        } else {
            return .noError
        }
    }
}


// MARK: - SpoonyTextFieldStyle
public enum SpoonyTextFieldStyle: Equatable {
    case normal(isIcon: Bool)
    case icon
    case count
    
    var iconSize: CGFloat? {
        switch self {
        case .normal:
            return 24.adjusted
        case .icon:
            return 20.adjusted
        case .count:
            return nil
        }
    }
    
    var interSpacing: CGFloat {
        switch self {
        case .normal, .count:
            return 12
        case .icon:
            return 16
        }
    }
    
    var leadingIcon: String? {
        switch self {
        case .normal, .count:
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
            return "ic_delete_gray400"
        case .count:
            return nil
        }
    }
    
    var isBorder: Bool {
        switch self {
        case .normal, .count:
            return true
        case .icon:
            return false
        }
    }
    
    var isLeadingIcon: Bool {
        switch self {
        case .icon:
            return true
        case .normal, .count:
            return false
        }
    }
    
    var isTrailingItem: Bool {
        switch self {
        case .normal(let isIcon):
            return isIcon
        case .icon, .count:
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
    
    var errorMessage: String? {
        switch self {
        case .maximumInputError:
            return "글자 수 30자 이하로 입력해 주세요"
        case .minimumInputError:
            return "한 줄 소개는 필수예요"
        case .noError, .invalidInputError:
            return nil
        }
    }
}
