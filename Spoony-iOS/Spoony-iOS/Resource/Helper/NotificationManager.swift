//
//  NotificationManager.swift
//  Spoony-iOS
//
//  Created by 최주리 on 6/16/25.
//

import Foundation

enum NotificationManager {
    static let loginNotificationPublisher = NotificationCenter.default.publisher(for: .loginNotification)
}

extension Notification.Name {
    static let loginNotification = Notification.Name("LoginNotification")
}

