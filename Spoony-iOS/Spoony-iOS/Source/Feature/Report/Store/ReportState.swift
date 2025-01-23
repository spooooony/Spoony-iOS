//
//  ReportState.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/23/25.
//

import Foundation

struct ReportState {
    var selectedReport: ReportType = .advertisement
    var description: String = ""
    
    var isError: Bool = true
    var isDisabled: Bool = true
}
