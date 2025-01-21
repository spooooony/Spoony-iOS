//
//  ReportRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

struct ReportRequest: Encodable {
    var postId: Int
    var userId: Int
    var reportType: String
    var reportDetail: String
}
