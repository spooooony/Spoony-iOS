//
//  RegisterServiceKey.swift
//  Spoony-iOS
//
//  Created by 최주리 on 5/12/25.
//

import Dependencies

enum ReportServiceKey: DependencyKey {
    static let liveValue: ReportProtocol = DefaultReportService()
}
