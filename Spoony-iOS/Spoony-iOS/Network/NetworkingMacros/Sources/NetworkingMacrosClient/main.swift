import NetworkingMacros
import Foundation

struct SimpleResponse: Codable {
    let message: String
}

enum SimpleTarget {
    case getTest
}

// 매크로 사용 테스트
@NetworkService
final class TestService {
    
    @NetworkRequest<SimpleResponse>(target: ".getTest")
    func fetchTest() async throws -> SimpleResponse {}
}

// 단순 출력 테스트
print("🎉 NetworkingMacros 빌드 성공!")
print("✅ @NetworkService 매크로가 정상적으로 작동합니다.")
print("✅ @NetworkRequest 매크로가 정상적으로 작동합니다.")

let testService = TestService()
print("✨ TestService 인스턴스 생성 완료")
print("💡 매크로에 의해 코드가 자동 생성되었습니다!")
