//
//  PlaceInfoCell.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

struct PlaceInfoCell: View {
    let placeInfo: PlaceInfo
    let placeInfoType: PlaceInfoType
    let action: (() -> Void)?
    
    init(
        placeInfo: PlaceInfo,
        placeInfoType: PlaceInfoType,
        action: (() -> Void)? = nil
    ) {
        self.placeInfo = placeInfo
        self.placeInfoType = placeInfoType
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Image(.icPinGray900)
                    .resizable()
                    .frame(width: 20.adjusted, height: 20.adjustedH)
                    .padding(.trailing, placeInfoType.leadingIconSpacing)
                VStack(alignment: .leading, spacing: 2) {
                    Text(placeInfo.placeName)
                        .font(.body2b)
                        .foregroundStyle(.spoonBlack)
                    
                    Text(placeInfo.placeRoadAddress)
                        .font(.caption1m)
                        .foregroundStyle(.gray500)
                }
                
                Spacer()
            }
            if placeInfoType.isIcon {
                Button {
                    action?()
                } label: {
                    Image(.icDeleteFillGray400)
                        .resizable()
                        .frame(width: 24.adjusted, height: 24.adjustedH)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, placeInfoType.horizontalSpacing)
        .padding(.vertical, placeInfoType.verticalSpacing)
        .frame(width: 335.adjusted, height: placeInfoType.height)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.1))
                .strokeBorder(placeInfoType.isIcon ? .gray100 : .clear)
        }
    }
}
