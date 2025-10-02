//
//  SplashInterface.swift
//  Spoony
//
//  Created by 최주리 on 10/2/25.
//

import Foundation

protocol SplashInterface {
    func checkAutoLogin() -> Bool
    func refresh() async throws
}
