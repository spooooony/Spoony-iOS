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
    @State var errorState: TextEditorErrorState = .noError
    @Binding var text: String
    @FocusState private var isFocused
    
    let placeholder: String
    let style: SpoonyTextEditorStyle
    
    // MARK: - Init
    public init(
        text: Binding<String>,
        placeholder: String,
        style: SpoonyTextEditorStyle
    ) {
        self._text = text
        self.placeholder = placeholder
        self.style = style
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
            if errorState == .noError, isFocused {
                return .main400
            } else if errorState == .noError {
                return .gray100
            } else {
                return .error400
            }
        }()
        
        return VStack(alignment: .trailing, spacing: 4) {
            TextEditor(text: $text)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($isFocused)
                .font(.body2m)
                .background(.red)
                .overlay(alignment: .topLeading) {
                    Text("\(placeholder)")
                        .font(.body2m)
                        .foregroundStyle(text.isEmpty ? .gray500 : .clear)
                        .offset(x: 5.adjusted, y: 8.adjustedH)
                }
                .onChange(of: text) { _, newValue in
                    switch checkInputError(newValue) {
                    case .maximumInputError(style: let style):
                        errorState = .maximumInputError(style: style)
                        text = String(newValue.prefix(style.maximumInput))
                    case .minimumInputError(style: let style):
                        errorState = .minimumInputError(style: style)
                    case .noError:
                        errorState = .noError
                    }
                }
                .onChange(of: isFocused) { _, newValue in
                    if !newValue, errorState.isMaximumInputError {
                        errorState = .noError
                    }
                }

            Text("\(text.count) / \(style.maximumInput)")
                .font(.caption1m)
                .foregroundStyle(errorState != .noError ? .error400 : .gray500)
                .padding(.trailing, 5)
                .padding(.bottom, 7)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 5)
        .frame(width: 335.adjusted, height: 125.adjustedH)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 1)
        }
    }
    
    // MARK: - errorMessageView
    private func errorMessageView(_ message: String) -> some View {
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

// MARK: - Functions
extension SpoonyTextEditor {
    private func checkInputError(_ input: String) -> TextEditorErrorState {
        let trimmedText = text.replacingOccurrences(of: " ", with: "")
        
        switch style {
        case .review:
            if input.count < style.minimumInput {
                return .minimumInputError(style: .review)
            } else if input.count > style.maximumInput {
                return .maximumInputError(style: .review)
            } else if errorState == .maximumInputError(style: .review),
                      input.count == style.maximumInput {
                return .maximumInputError(style: .review)
            } else {
                return .noError
            }
        case .report:
            if trimmedText.count < style.minimumInput {
                return .minimumInputError(style: .report)
            } else if input.count > style.maximumInput {
                return .maximumInputError(style: .report)
            } else if errorState == .maximumInputError(style: .report),
                      input.count == style.maximumInput {
                return .maximumInputError(style: .report)
            } else {
                return .noError
            }
        }
    }

}

// MARK: - SpoonyTextEditorStyle
public enum SpoonyTextEditorStyle {
    case review
    case report
    
    var maximumInput: Int {
        switch self {
        case .review:
            return 500
        case .report:
            return 300
        }
    }
    
    var minimumInput: Int {
        switch self {
        case .review:
            return 50
        case .report:
            return 1
        }
    }
}

// MARK: - TextEditorErrorState
public enum TextEditorErrorState: Equatable {
    case maximumInputError(style: SpoonyTextEditorStyle)
    case minimumInputError(style: SpoonyTextEditorStyle)
    case noError
    
    var errorMessage: String? {
        switch self {
        case .maximumInputError(let style):
            switch style {
            default:
                return "글자 수 \(style.maximumInput)자 이하로 입력해 주세요"
            }
        case .minimumInputError(let style):
            switch style {
            case .review:
                return "자세한 후기는 필수예요"
            case .report:
                return "내용 작성은 필수예요"
            }
        case .noError:
            return nil
        }
    }
    
    var isMaximumInputError: Bool {
        self == .maximumInputError(style: .review) || self == .maximumInputError(style: .report)
    }
}
