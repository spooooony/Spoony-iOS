//
//  SpoonyTextEditor.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/15/25.
//

import SwiftUI

/// SpoonyTextField
/// - Parameters:
///   - placeholder: 플레이스 홀더 메시지
///   - style: 텍스트 필드 스타일
public struct SpoonyTextEditor: View {
    
    // MARK: - Properties
    @State private var errorState: TextEditorErrorState = .initial
    @FocusState private var isFocused
    @Binding var text: String
    @Binding var isError: Bool
    
    private let placeholder: String
    private let style: SpoonyTextEditorStyle
    
    // MARK: - Init
    public init(
        text: Binding<String>,
        style: SpoonyTextEditorStyle,
        placeholder: String,
        isError: Binding<Bool>
    ) {
        self._text = text
        self.style = style
        self.placeholder = placeholder
        self._isError = isError
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            customTextEditor
            
            if let message = errorState.errorMessage, errorState != .noError {
                errorMessageView(message)
            }
        }
    }
}

extension SpoonyTextEditor {
    
    // MARK: - customTextEditor
    private var customTextEditor: some View {
        let borderColor: Color = {
            if isFocused {
                if style == .profileEdit {
                    return errorState == .noError || errorState == .initial ? .gray100 : .error400
                } else {
                    return errorState == .noError || errorState == .initial ? .main400 : .error400
                }
            } else {
                return errorState == .noError || errorState == .initial ? .gray100 : .error400
            }
        }()
        
        return VStack(alignment: .trailing, spacing: 4) {
            TextEditor(text: $text)
                .padding(.trailing, 5)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($isFocused)
                .customFont(.body2m)
                .overlay(alignment: .topLeading) {
                    Text("\(placeholder.splitZeroWidthSpace())")
                        .customFont(.body2m)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(text.isEmpty ? .gray500 : .clear)
                        .offset(x: 5.adjusted, y: 8.adjustedH)
                }
                .onChange(of: text) { _, newValue in
                    if style == .profileEdit || style == .onboarding {
                        text = newValue.removeEmogi()
                    }                    
                    
                    switch checkInputError(text) {
                    case .maximumInputError(let style):
                        errorState = .maximumInputError(style: style)
                        text = String(newValue.prefix(style.maximumInput))
                    case .minimumInputError(let style):
                        errorState = .minimumInputError(style: style)
                    case .noError, .initial:
                        errorState = .noError
                    }
                }
                .onChange(of: isFocused) { _, newValue in
                    print(errorState)
                    if !newValue, errorState.isMaximumInputError {
                        errorState = .noError
                    }
                }
                .onChange(of: errorState) {
                    switch errorState {
                    case .minimumInputError:
                        isError = true
                    default:
                        isError = false
                    }
                }

            Text("\(text.count) / \(style.maximumInput)")
                .customFont(.caption1m)
                .foregroundStyle(errorState != .noError && errorState != .initial ? .error400 : .gray500)
                .padding(.trailing, 5)
                .padding(.bottom, 7)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .frame(width: style.width, height: style.height)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }
    
    // MARK: - errorMessageView
    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: 6) {
            if !message.isEmpty {
                Image(.icErrorRed)
                    .resizable()
                    .frame(width: 16.adjusted, height: 16.adjusted)
            }
            
            Text("\(message)")
                .customFont(.caption1m)
                .foregroundStyle(.error400)
        }
    }
}

// MARK: - Functions
extension SpoonyTextEditor {
    private func checkInputError(_ input: String) -> TextEditorErrorState {
        let trimmedText = text.replacingOccurrences(of: " ", with: "")
        let currentInputLength = style == .report ? trimmedText.count : input.count

         if currentInputLength < style.minimumInput {
             return .minimumInputError(style: style)
         } else if input.count > style.maximumInput {
             return .maximumInputError(style: style)
         } else if errorState == .maximumInputError(style: style),
                   input.count == style.maximumInput {
             return .maximumInputError(style: style)
         } else {
             return .noError
         }
    }
}

// MARK: - SpoonyTextEditorStyle
public enum SpoonyTextEditorStyle {
    case review
    case report
    case onboarding
    case profileEdit
    case weakPoint
    
    var maximumInput: Int {
        switch self {
        case .review:
            return 500
        case .report:
            return 300
        case .onboarding:
            return 50
        case .profileEdit:
            return 50
        case .weakPoint:
            return 100
        }
    }
    
    var minimumInput: Int {
        switch self {
        case .review, .report, .onboarding:
            return 1
        case .profileEdit, .weakPoint:
            return 0
        }
    }
    
    var width: CGFloat {
        switch self {
        case .review, .report, .onboarding, .profileEdit, .weakPoint:
            return 335.adjusted
        }
    }
    
    var height: CGFloat {
        switch self {
        case .review, .report, .onboarding, .weakPoint:
            return 125.adjustedH
        case .profileEdit:
            return 65.adjustedH
        }
    }
}

// MARK: - TextEditorErrorState
public enum TextEditorErrorState: Equatable {
    case maximumInputError(style: SpoonyTextEditorStyle)
    case minimumInputError(style: SpoonyTextEditorStyle)
    case noError
    case initial
    
    var errorMessage: String? {
        switch self {
        case .maximumInputError(let style):
            return "글자 수 \(style.maximumInput)자 이하로 입력해 주세요"
        case .minimumInputError(let style):
            switch style {
            case .review:
                return "자세한 후기는 필수예요"
            case .report:
                return "내용 작성은 필수예요"
            case .onboarding, .profileEdit, .weakPoint:
                return ""
            }
        case .noError, .initial:
            return nil
        }
    }
    
    var isMaximumInputError: Bool {
        self == .maximumInputError(style: .review) ||
        self == .maximumInputError(style: .report) ||
        self == .maximumInputError(style: .profileEdit) ||
        self == .maximumInputError(style: .weakPoint) ||
        self == .maximumInputError(style: .onboarding)
    }
}

#Preview {
    SpoonyTextEditor(text: .constant(" "), style: .review, placeholder: "dk", isError: .constant(true))
}
