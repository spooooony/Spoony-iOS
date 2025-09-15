//
//  ToastType.swift
//  Spoony
//
//  Created by 최안용 on 9/11/25.
//

import Foundation

enum ToastType {
    case serverError
    case imageError
    case noSearchResult
    case alreadyRegistered
    case unknownError
    case blockUser
    case unBlockUser
    case savedToMap
    case deletedFromMap
    case noSpoon
    case zzimError
    case spoonError
    case userError
    case reviewDeleteSuccess
    case reviewDeleteFail
    
    var message: String {
        switch self {
        case .serverError:
            return "서버에 연결할 수 없습니다.\n잠시 후 다시 시도해 주세요."
        case .imageError:
            return "이미지를 불러올 수 없습니다.\n잠시 후 다시 시도해 주세요."
        case .noSearchResult:
            return "검색 결과가 없습니다."
        case .alreadyRegistered:
            return "앗! 이미 등록한 맛집이에요"
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다."
        case .blockUser:
            return "해당 유저가 차단되었어요."
        case .unBlockUser:
            return "해당 유저가 차단 해제되었어요."
        case .savedToMap:
            return "내 지도에 저장되었어요."
        case .deletedFromMap:
            return "내 지도에서 삭제되었어요."
        case .noSpoon:
            return "남은 스푼이 없어요 ㅠ.ㅠ"
        case .zzimError:
            return "스크랩에 실패했습니다."
        case .spoonError:
            return "떠먹기에 실패 했습니다."
        case .userError:
            return "해당 유저를 불러올 수 없습니다."
        case .reviewDeleteSuccess:
            return "삭제가 완료되었어요."
        case .reviewDeleteFail:
            return "삭제에 실패했어요. 다시 시도해주세요."
        }
    }
}
