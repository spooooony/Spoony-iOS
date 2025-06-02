//
//  RegionResponse.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/4/25.
//

import Foundation

struct RegionListResponse: Codable {
    let regionList: [RegionResponse]
}

extension RegionListResponse {
    struct RegionResponse: Codable {
        let regionId: Int
        let regionName: String
    }
}

extension RegionListResponse {
    func toEntity() -> [Region] {
        return regionList.map {
            .init(id: $0.regionId, regionName: $0.regionName)
        }
    }
}
