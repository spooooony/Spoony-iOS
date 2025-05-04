//
//  ValidatePlaceRequest.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/21/25.
//

import Foundation

struct ValidatePlaceRequest: Encodable {
    let userId: Int
    let latitude: Double
    let longitude: Double
}
