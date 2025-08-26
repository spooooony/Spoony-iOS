//
//  RegisterTargetType.swift
//  Spoony-iOS
//
//  Created by 이명진 on 1/20/25.
//

import Foundation
import Moya

enum RegisterTargetType {
    case searchPlace(query: String)
    case validatePlace(request: ValidatePlaceRequest)
    case registerPost(request: RegisterPostRequest, imagesDate: [Data])
    case editPost(request: EditPostRequest, imagesDate: [Data])
    case getRegisterCategories
    case getReviewInfo(postId: Int)
}

extension RegisterTargetType: TargetType {
    
    var baseURL: URL {
        guard let url = URL(string: Config.baseURL) else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .searchPlace:
            return "/place/search"
        case .validatePlace:
            return "/place/check"
        case .registerPost, .editPost:
            return "/post"
        case .getRegisterCategories:
            return "/post/categories/food"
        case .getReviewInfo(let postId):
            return "/post/\(postId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .searchPlace, .getRegisterCategories, .getReviewInfo:
            return .get
        case .validatePlace, .registerPost:
            return .post
        case .editPost:
            return .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .searchPlace(let query):
            return .requestParameters(
                parameters: ["query": query],
                encoding: URLEncoding.queryString
            )
        case .getRegisterCategories, .getReviewInfo:
            return .requestPlain
        case .validatePlace(let request):
            return .requestJSONEncodable(request)
        case let .registerPost(request, imagesData):
            guard let multipartData = createMultipartData(from: request, images: imagesData) else {
                fatalError("Multipart data could not be created")
            }
            
            return .uploadMultipart(multipartData)
        case let .editPost(request, imagesDate):
            guard let multipartData = createMultipartData(from: request, images: imagesDate) else {
                fatalError("Multipart data could not be created")
            }
            return .uploadMultipart(multipartData)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .searchPlace, .getRegisterCategories, .validatePlace, .getReviewInfo:
//            return Config.defaultHeader
            return HeaderType.auth.value
        case .registerPost, .editPost:
            return HeaderType.multipart.value
        }
    }
}

extension RegisterTargetType {
    private func createMultipartData<T>(from request: T, images: [Data]) -> [MultipartFormData]? where T: Codable {
        var formData: [MultipartFormData] = []
        
        guard let jsonObject = try? JSONEncoder().encode(request),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonObject),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            print("Failed to serialize RegisterPostRequest to JSON string")
            return nil
        }
        
        formData.append(MultipartFormData(
            provider: .data(jsonData),
            name: "data",
            mimeType: "application/json"
        ))
        
        for (index, imageData) in images.enumerated() {
            let fileName = "image\(index + 1).jpeg"
            let mimeType = "image/jpeg"
            
            formData.append(MultipartFormData(
                provider: .data(imageData),
                name: "photos",
                fileName: fileName,
                mimeType: mimeType
            ))
        }
        
        return formData
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
