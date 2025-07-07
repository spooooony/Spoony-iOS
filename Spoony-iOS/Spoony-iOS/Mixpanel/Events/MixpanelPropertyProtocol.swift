//
//  MixpanelPropertyProtocol.swift
//  Spoony-iOS
//
//  Created by 최안용 on 7/4/25.
//

import Mixpanel

protocol MixpanelProperty {
    var dictionary: [String: MixpanelType] { get }
}
