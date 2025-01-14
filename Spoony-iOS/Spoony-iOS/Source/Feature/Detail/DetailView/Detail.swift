//
//  Detail.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/2/25.
//

import SwiftUI
import NMapsMap

struct Detail: View {
    
    private var searchName = "매운집"
    private var appName: String = "Spoony"
    
    var body: some View {
        SpoonyButton(style: .primary, size: .large, title: "샤갈 네이버", disabled: .constant(false)) {
            let url = URL(string: "nmap://search?query=\(searchName)&appname=\(appName)")!
            let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
}

#Preview {
    Detail()
}
