//
//  UserReportRequest.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/11/25.
//

import Foundation

struct UserReportRequest: Encodable {
    var targetUserId: Int
    var userReportType: String
    var reportDetail: String
}
