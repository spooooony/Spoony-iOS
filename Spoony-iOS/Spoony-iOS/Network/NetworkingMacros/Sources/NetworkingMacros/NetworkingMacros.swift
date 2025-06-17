// The Swift Programming Language
// https://docs.swift.org/swift-book

/// 네트워킹 서비스 클래스에 provider와 performRequest 메서드를 자동으로 추가하는 매크로
///
/// 사용법:
/// ```swift
/// @NetworkService
/// final class HomeService {
///     // provider와 performRequest 메서드가 자동으로 생성됨
/// }
/// ```
@attached(member, names: named(provider))
@attached(extension, conformances: ServiceType, names: named(performRequest), named(TargetType))
public macro NetworkService() = #externalMacro(module: "NetworkingMacrosMacros", type: "NetworkServiceMacro")

/// 비동기 네트워크 요청을 위한 표준 구현을 자동 생성하는 매크로
@attached(body)
public macro NetworkRequest<T>(
    target: String,
    errorHandling: ErrorHandlingStrategy = .standard
) = #externalMacro(module: "NetworkingMacrosMacros", type: "NetworkRequestMacro")

/// 에러 처리 전략을 정의하는 열거형
public enum ErrorHandlingStrategy {
    case standard
    case customMessage
    case spoonService
}

/// 네트워킹 서비스가 구현해야 하는 프로토콜
public protocol ServiceType {
    associatedtype TargetType
    /// 네트워크 요청을 수행하는 메서드
    func performRequest<T: Codable>(_ target: TargetType, responseType: T.Type) async throws -> T
}
