//
//  ReportIntent.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/23/25.
//

import Foundation

enum ReportIntent {
    case reportReasonButtonTapped(ReportType)
    case reportPostButtonTapped(Int)
    case backgroundTapped
    case backButtonTapped

    case descriptionChanged(String)
    case isErrorChanged(Bool)
    
    case onAppear(NavigationManager)
}
