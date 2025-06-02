//
//  SpoonyLocationPicker.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/15/25.
//

import SwiftUI

struct SpoonyLocationPicker: View {
    private let locationList: [Region]
    @State var isPresented: Bool = false
    @Binding var selectedLocation: LocationType
    @Binding var selectedSubLocation: Region?
    
    init(
        locationList: [Region],
        selectedLocation: Binding<LocationType>,
        selectedSubLocation: Binding<Region?>
    ) {
        self.locationList = locationList
        self._selectedLocation = selectedLocation
        self._selectedSubLocation = selectedSubLocation
    }
    
    var body: some View {
        HStack(spacing: 22) {
            Text("나는")
            placeholderWithImageView(selectedLocation, selectedSubLocation)
                .onTapGesture {
                    isPresented = true
                }
            Text("스푼")
        }
        .frame(maxWidth: .infinity)
        .customFont(.body1m)
        .sheet(isPresented: $isPresented) {
            LocationPickerBottomSheet(
                isPresented: $isPresented,
                selectedLocation: $selectedLocation,
                selectedSubLocation: $selectedSubLocation,
                regionList: locationList
            )
            .presentationDetents([.height(542.adjustedH)])
            .presentationCornerRadius(16)
        }
    }
}

extension SpoonyLocationPicker {
    private func placeholderWithImageView(_ location: LocationType, _ subLocation: Region?) -> some View {
        let locationTitle = location.rawValue
        var subLocationTitle: String {
            if let subLocation {
                subLocation.regionName
            } else {
                "마포구"
            }
        }
        let isSelected = subLocation != nil
        
        return HStack(spacing: 8) {
            Image(.icSpoonGray600)
                .renderingMode(.template)
                .foregroundStyle(isSelected ? .main400 : .gray400)
            
            Text("\(locationTitle) \(subLocationTitle)")
                .customFont(.body2m)
                .foregroundStyle(isSelected ? .spoonBlack : .gray400)
        }
        .frame(height: 44.adjustedH)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.gray100), lineWidth: 1)
        )
    }
}

#Preview {
    SpoonyLocationPicker(locationList: [], selectedLocation: .constant(.busan), selectedSubLocation: .constant(nil))
}
