//
//  MyPageTargetType.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/3/25.
//

import Foundation
import Moya

enum MyPageTargetType {
    case followUser(request: TargetUserRequest)
    case cancelFollowUser(request: TargetUserRequest)
    case blockUser(request: TargetUserRequest)
    case unblockUser(request: TargetUserRequest)
    case getProfileInfo
    case editProfileInfo(request: EditProfileRequest)
    case getUserInfo
    case getOtherInfo(userId: Int)
    case getOtherReviews(userId: Int)
    case getUserReviews
    case searchUser(query: String)
    case getUserRegion
    case getProfileImages
    case getFollowinglist
    case getFollowerlist
    case nicknameDuplicateCheck(query: String)
    case getBlockedUsers
    case deleteReview(postId: Int)
}

extension MyPageTargetType: TargetType {
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .followUser, .cancelFollowUser:
            return "/user/follow"
        case .blockUser, .unblockUser:
            return "/user/block"
        case .getProfileInfo, .editProfileInfo:
            return "/user/profile"
        case .getUserInfo:
            return "/user"
        case .getOtherInfo(let userId):
            return "/user/\(userId)"
        case .getOtherReviews(let userId):
            return "/user/reviews/\(userId)"
        case .getUserReviews:
            return "/user/reviews"
        case .searchUser:
            return "/user/search"
        case .getUserRegion:
            return "/user/region"
        case .getProfileImages:
            return "/user/profile/images"
        case .getFollowinglist:
            return "/user/followings"
        case .getFollowerlist:
            return "/user/followers"
        case .nicknameDuplicateCheck:
            return "/user/exists"
        case .getBlockedUsers:
            return "/user/blockings"
        case .deleteReview(let postId):
            return "/post/\(postId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .followUser, .blockUser:
            return .post
        case .cancelFollowUser, .unblockUser, .deleteReview:
            return .delete
        case .editProfileInfo:
            return .patch
        case .getProfileInfo,
                .getUserInfo,
                .getOtherInfo,
                .getOtherReviews,
                .getUserReviews,
                .searchUser,
                .getUserRegion,
                .getProfileImages,
                .getFollowinglist,
                .getFollowerlist,
                .nicknameDuplicateCheck,
                .getBlockedUsers:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .followUser(let request),
                .cancelFollowUser(let request),
                .blockUser(let request),
                .unblockUser(let request):
            return .requestJSONEncodable(request)
        case .editProfileInfo(let request):
            return .requestJSONEncodable(request)
        case .searchUser(let query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.default
            )
        case .nicknameDuplicateCheck(let query):
            return .requestParameters(
                parameters: ["userName": query],
                encoding: URLEncoding.default
            )
        case .getOtherReviews:
            return .requestParameters(
                parameters: ["isLocalReview": false],
                encoding: URLEncoding.queryString
            )
        case .getProfileInfo,
                .getUserInfo,
                .getOtherInfo,
                .getUserReviews,
                .getUserRegion,
                .getProfileImages,
                .getFollowinglist,
                .getFollowerlist,
                .getBlockedUsers,
                .deleteReview:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return HeaderType.auth.value
    }
}
