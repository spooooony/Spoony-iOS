//
//  InfoStepView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import SwiftUI

struct InfoStepView: View {
    @ObservedObject private var store: RegisterStore
    @State private var isDropDown: Bool = false
    
    init(store: RegisterStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            sectionGroup
            
            nextButton
        }
        .background(.white)
        .onTapGesture {
            isDropDown = false
            hideKeyboard()
        }
        .toastView(toast: $store.toast)
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
                SpoonyTextField(
                    text: Binding(
                        get: { store.text },
                        set: { newValue in
                            store.text = newValue
                        }
                    ),
                    style: .icon,
                    placeholder: "어떤 장소를 한 입 줄까요?",
                    isError: .constant(false)
                ) {
                    store.text = ""
                    isDropDown = false
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
        VStack(alignment: .leading, spacing: 0) {
            Text("추천 메뉴를 알려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 12)
            
            VStack(spacing: 8) {
                ForEach(Array(store.recommendMenu.enumerated()), id: \.offset) { index, _ in
                    SpoonyTextField(
                        text: $store.recommendMenu[index],
                        style: .normal(isIcon: store.recommendMenu.count > 1),
                        placeholder: "메뉴 이름",
                        isError: .constant(false)
                    ) {
                        guard index < store.recommendMenu.count else { return }
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
        VStack(spacing: 0) {
            ForEach(store.searchPlaces, id: \.id) { place in
                PlaceInfoCell(placeInfo: place, placeInfoType: .listCell)
                    .onTapGesture {
                        store.selectedPlace = place
                        store.isSelected = true
                        isDropDown = false
                        store.text = ""
                        store.toast = .init(style: .gray, message: "앗! 이미 등록한 맛집이에요", yOffset: 556.adjustedH)
                    }
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1.adjusted)
                            .foregroundStyle(.gray100)
                    }
            }
        }
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.gray100, lineWidth: 1)
        }
        .shadow(color: .gray0, radius: 16, x: 0, y: 2)
    }
    
    private var plusButton: some View {
        return Button {
            store.plusButtonTapped()
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
        .disabled(store.plusButtonDisabled)
    }
    
    private var nextButton: some View {
        SpoonyButton(
            style: .primary,
            size: .xlarge,
            title: "다음",
            disabled: $store.disableFirstButton
        ) {
            store.step = .middle
        }
        .padding(.bottom, 20)
        .padding(.top, 61)
        .overlay(alignment: .top) {
            ToolTipView()
                .padding(.top, 5)
                .opacity(store.isToolTipPresented ? 1 : 0)
                .task {
                    do {
                        try await Task.sleep(for: .seconds(3))
                        store.isToolTipPresented = false
                    } catch {
                        
                    }
                    
                }
        }
    }
}

#Preview {
    InfoStepView(store: .init())
}
