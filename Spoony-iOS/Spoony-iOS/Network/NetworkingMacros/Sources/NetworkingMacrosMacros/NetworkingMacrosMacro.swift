import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct NetworkingMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NetworkServiceMacro.self,
        NetworkRequestMacro.self,
    ]
}

/// @NetworkService 매크로 구현체
public struct NetworkServiceMacro: MemberMacro, ExtensionMacro {
    
    // MARK: - MemberMacro 구현
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        // 클래스에만 적용 가능하도록 검증
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.onlyApplicableToClass
        }
        
        // 클래스 이름에서 Service 종류 추출 (예: DefaultHomeService -> home)
        let className = classDecl.name.text
        let providerName = extractProviderName(from: className)
        
        // provider 프로퍼티 생성
        let providerDecl: DeclSyntax = """
            private let provider = Providers.\(raw: providerName)Provider
            """
        
        return [providerDecl]
    }
    
    // MARK: - ExtensionMacro 구현
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        // 클래스 이름에서 TargetType 추출
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw MacroError.onlyApplicableToClass
        }
        
        let className = classDecl.name.text
        let targetTypeName = extractTargetTypeName(from: className)
        
        // ServiceType 프로토콜 준수 extension 생성
        let extensionDecl = try ExtensionDeclSyntax("extension \(type): ServiceType") {
            """
            typealias TargetType = \(raw: targetTypeName)
            """
            
            try FunctionDeclSyntax("func performRequest<T: Codable>(_ target: \(raw: targetTypeName), responseType: T.Type) async throws -> T") {
                """
                return try await withCheckedThrowingContinuation { continuation in
                    provider.request(target) { result in
                        switch result {
                        case .success(let response):
                            do {
                                let baseResponse = try response.map(BaseResponse<T>.self)
                                if baseResponse.success, let data = baseResponse.data {
                                    continuation.resume(returning: data)
                                } else {
                                    continuation.resume(throwing: SNError.noData)
                                }
                            } catch {
                                continuation.resume(throwing: SNError.decodeError)
                            }
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                """
            }
        }
        
        return [extensionDecl]
    }
    
    // 클래스 이름에서 provider 이름 추출
    private static func extractProviderName(from className: String) -> String {
        // DefaultHomeService -> home
        // ExploreService -> explor
        //(Providers.explorProvider에 맞춤)
        if className.contains("Home") {
            return "home"
        } else if className.contains("Explore") {
            return "explor"
        } else if className.contains("Register") {
            return "register"
        } else if className.contains("Post") {
            return "post"
        } else if className.contains("Auth") {
            return "auth"
        } else if className.contains("MyPage") {
            return "myPage"
        } else if className.contains("Image") {
            return "image"
        } else if className.contains("Follow") {
            return "follow"
        } else if className.contains("SpoonDraw") {
            return "spoonDraw"
        } else {
            return "home" // 기본값
        }
    }
    
    // 클래스 이름에서 TargetType 이름 추출
    private static func extractTargetTypeName(from className: String) -> String {
        // DefaultHomeService -> HomeTargetType
        if className.contains("Home") {
            return "HomeTargetType"
        } else if className.contains("Explore") {
            return "ExploreTargetType"
        } else if className.contains("Register") {
            return "RegisterTargetType"
        } else if className.contains("Post") {
            return "PostTargetType"
        } else if className.contains("Auth") {
            return "AuthTargetType"
        } else if className.contains("MyPage") {
            return "MyPageTargetType"
        } else if className.contains("Image") {
            return "ImageLoadTargetType"
        } else if className.contains("Follow") {
            return "FollowTargetType"
        } else if className.contains("SpoonDraw") {
            return "SpoonDrawTargetType"
        } else {
            return "HomeTargetType" // 기본값
        }
    }
}

/// @NetworkRequest 매크로 구현체
public struct NetworkRequestMacro: BodyMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        
        // 함수 선언만 허용
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw MacroError.onlyApplicableToFunction
        }
        
        // 매크로 인자에서 target 추출
        let arguments = node.arguments?.as(LabeledExprListSyntax.self)
        guard let targetExpr = arguments?.first(where: { $0.label?.text == "target" })?.expression else {
            throw MacroError.missingRequiredArgument("target")
        }
        
        // 리턴 타입 추출
        let returnType = extractReturnType(from: funcDecl)
        
        // target 문자열 정리 (따옴표와 점 제거)
        let targetString = targetExpr.trimmed.description
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        // 간단한 바디 생성
        let body: [CodeBlockItemSyntax] = [
            """
            return try await performRequest(.\(raw: targetString), responseType: \(raw: returnType).self)
            """
        ]
        
        return body
    }
    
    /// 함수 리턴 타입 추출
    private static func extractReturnType(from funcDecl: FunctionDeclSyntax) -> String {
        guard let returnClause = funcDecl.signature.returnClause else {
            return "Void"
        }
        return returnClause.type.trimmed.description
    }
}

/// 매크로 에러 타입
public enum MacroError: Error, CustomStringConvertible {
    case onlyApplicableToClass
    case onlyApplicableToFunction
    case missingRequiredArgument(String)
    
    public var description: String {
        switch self {
        case .onlyApplicableToClass:
            return "@NetworkService는 클래스에만 적용할 수 있습니다."
        case .onlyApplicableToFunction:
            return "@NetworkRequest는 함수에만 적용할 수 있습니다."
        case .missingRequiredArgument(let arg):
            return "필수 인자 '\(arg)'이 누락되었습니다."
        }
    }
}
