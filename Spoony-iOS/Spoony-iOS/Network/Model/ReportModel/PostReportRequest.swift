//
//  PostReportRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/22/25.
//

import Foundation

struct PostReportRequest: Encodable {
    var postId: Int
    var reportType: String
    var reportDetail: String
}
