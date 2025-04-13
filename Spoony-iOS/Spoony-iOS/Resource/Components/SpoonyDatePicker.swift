//
//  SpoonyDatePicker.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/9/25.
//

import SwiftUI

struct SpoonyDatePicker: View {
    @State var isPresent: Bool = false
    @Binding var selectedDate: [String]
    
    var body: some View {
        HStack(spacing: 21.adjusted) {
            ForEach(DateType.allCases, id: \.self) { type in
                HStack(spacing: 10.adjusted) {
                    DateButton(type)
                    Text("\(type.title)")
                        .font(.body1m)
                        .foregroundStyle(.gray500)
                }
            }
        }
        .sheet(isPresented: $isPresent) {
            DatePickerBottomSheet(isPresented: $isPresent, selectedDate: $selectedDate)
                .presentationDetents([.height(296.adjustedH)])
                .presentationCornerRadius(16)
        }
    }
}

extension SpoonyDatePicker {
    private func DateButton(_ type: DateType) -> some View {
        Text("\(selectedDate[type.rawValue].isEmpty ? type.placeHolder : selectedDate[type.rawValue])")
            .font(.body1m)
            .foregroundStyle(selectedDate[type.rawValue].isEmpty ? .gray500 : .spoonBlack)
            .frame(width: type.width, height: 44.adjustedH)
        
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.clear)
                    .strokeBorder(.gray100)
            }
            .onTapGesture {
                isPresent.toggle()
            }
    }
}

#Preview {
    SpoonyDatePicker(selectedDate: .constant(["","",""]))
}
