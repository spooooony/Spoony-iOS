//
//  InfoStepView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import SwiftUI

struct InfoStepView: View {
    @ObservedObject var store: RegisterStore
    @State var isDropDown: Bool = false
    
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            sectionGroup
            
            SpoonyButton(
                style: .primary,
                size: .xlarge,
                title: "다음",
                disabled: $store.disableFirstButton
            ) {
                store.step = .middle
            }
            .padding(.bottom, 20)
        }
        .background(.white)
        .onTapGesture {
            isDropDown = false
            action()
        }
    }
}

extension InfoStepView {
    private var sectionGroup: some View {
        VStack(spacing: 0) {
            placeSection
                
            categorySection
            
            recommendSection
        }
        .overlay(alignment: .top) {
            if isDropDown {
                dropDownView
                    .padding(.top, 81)
            }
        }
        .padding(.horizontal, 20.adjusted)
        .padding(.bottom, 61)
    }
    
    private var titleView: some View {
        Text("나의 찐맛집을 등록해볼까요?")
            .font(.title2b)
            .foregroundStyle(.spoonBlack)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }
    
    private var placeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("장소명을 알려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            if !store.isSelected {
                SpoonyTextField(text: $store.text, style: .icon, placeholder: "어떤 장소를 한 입 줄까요?") {
                    store.text = ""
                }
                .onSubmit {
                    isDropDown = true
                }
            } else {
                if let place = store.selectedPlace {
                    PlaceInfoCell(placeInfo: place, placeInfoType: .selectedCell) {
                        store.selectedPlace = nil
                        store.isSelected = false
                    }
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리를 골라주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            ChipsContainerView(selectedItem: $store.selectedCategory, items: store.categorys)
        }
        .padding(.bottom, 40)
    }
    
    private var recommendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("추천 메뉴를 알려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 12)
            VStack {
                ForEach(store.recommendMenu.indices, id: \.self) { index in
                    SpoonyTextField(text: $store.recommendMenu[index], style: .normal(isIcon: store.recommendMenu.count > 1), placeholder: "메뉴 이름") {
                        store.recommendMenu.remove(at: index)
                    }
                }
                if store.recommendMenu.count < 3 {
                    plusButton
                }
            }
        }
    }
    
    private var dropDownView: some View {
        ScrollView {
            VStack(spacing: 1) {
                ForEach(store.searchPlaces, id: \.id) { place in
                    PlaceInfoCell(placeInfo: place, placeInfoType: .listCell)
                    .onTapGesture {
                        store.selectedPlace = place
                        store.isSelected = true
                        isDropDown = false
                        store.text = ""
                    }
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.gray100)
                }
            }
        }
        .lineSpacing(0)
        .scrollIndicators(.hidden)
        .frame(height: 189.adjustedH)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.gray100, lineWidth: 1)
        }
    }
    
    private var plusButton: some View {
        Button {
            store.recommendMenu.append("")
        } label: {
                Image(.icPlusGray400)
                    .resizable()
                    .frame(width: 20.adjusted, height: 20.adjustedH)
                    .frame(width: 335.adjusted, height: 44.adjustedH)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray0)
                            .strokeBorder(.gray100)
                    }
            }
        .buttonStyle(.plain)
    }
}

#Preview {
    InfoStepView(store: .init()) {
        
    }
}
