//
//  SpoonAttendanceView.swift
//  Spoony-iOS
//
//  Created by 이지훈 on 4/15/25.
//

import SwiftUI


struct SpoonAttendanceView: View {
    let day: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? .main100 : .gray100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(isSelected ? .main300 : .gray200, lineWidth: 8)
                    )
                    .frame(width: 105, height: 105)
                
                Image(isSelected ? "spoonyAttendance" : "unselectedAttendance")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                Text(day)
                    .font(.title3b)
                    .foregroundColor(isSelected ? .main300 : .gray400)
                    .frame(width: 90, height: 90, alignment: .topLeading)
                    .padding(.top, 12)
                    .padding(.leading, 16)
            }
            .frame(width: 105, height: 105)
        }
    }
}


