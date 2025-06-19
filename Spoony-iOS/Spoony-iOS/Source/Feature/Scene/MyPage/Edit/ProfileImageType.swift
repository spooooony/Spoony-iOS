//
//  ProfileImageType.swift
//  Spoony-iOS
//
//  Created by 최안용 on 5/31/25.
//

import Foundation

enum ProfileImageType: Equatable {
    case success(URL, Int)
    case lock(URL, Int)
    case fail(Int)
    
    var imageName: String {
        switch self {
        case .success:
            return ""
        case .lock:
            return "ic_lock"
        case .fail:
            return "ic_imageFail"
        }
    }
}
