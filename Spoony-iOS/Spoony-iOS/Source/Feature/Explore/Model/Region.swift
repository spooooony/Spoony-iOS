//
//  Region.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/28/25.
//

import Foundation

struct Region: Identifiable {
    let id: Int
    let regionName: String
}

extension Region {
    static func mock() -> [Region] {
        return [
            .init(id: 0, regionName: "강남구"),
            .init(id: 1, regionName: "강동구"),
            .init(id: 2, regionName: "강북구"),
            .init(id: 3, regionName: "강서구"),
            .init(id: 4, regionName: "관악구"),
            .init(id: 5, regionName: "광진구"),
            .init(id: 6, regionName: "구로구"),
            .init(id: 7, regionName: "금천구"),
            .init(id: 8, regionName: "노원구"),
            .init(id: 9, regionName: "도봉구"),
            .init(id: 10, regionName: "동대문구"),
            .init(id: 11, regionName: "동작구"),
            .init(id: 12, regionName: "마포구"),
            .init(id: 13, regionName: "서대문구"),
            .init(id: 14, regionName: "서초구")
        ]
    }
}
