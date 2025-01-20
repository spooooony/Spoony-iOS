//
//  InfoStepView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import SwiftUI

struct InfoStepView: View {
    @ObservedObject private var store: RegisterStore
    
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
            store.dispatch(.didTapBackground(.start))
            hideKeyboard()
        }
        .toastView(toast: Binding(get: {
            store.state.toast
        }, set: { newValue in
            store.dispatch(.updateToast(newValue))
        }))
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
            if store.state.isDropDownPresented {
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
            
            if store.state.selectedPlace == nil {
                SpoonyTextField(
                    text: Binding(
                        get: { store.state.placeText },
                        set: { newValue in
                            store.dispatch(.updateText(newValue, .place))
                        }
                    ),
                    style: .icon,
                    placeholder: "어떤 장소를 한 입 줄까요?",
                    isError: .constant(false)
                ) {
                    store.dispatch(.didTapButtonIcon(.place))
                }
                .onSubmit {
                    store.dispatch(.didTapkeyboardEnter)
                }
            } else {
                if let place = store.state.selectedPlace {
                    PlaceInfoCell(placeInfo: place, placeInfoType: .selectedCell) {
                        store.dispatch(.didTapPlaceInfoCellIcon)
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
            
            ChipsContainerView(
                selectedItem: Binding(get: {
                    store.state.selectedCategory
                }, set: { newValue in
                    store.dispatch(.updateSelectedCategoryChip(newValue))
                }),
                items: store.state.categorys
            )
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
                ForEach(store.state.recommendTexts, id: \.id) { text in
                    SpoonyTextField(
                        text: Binding(get: {
                            text.text
                        }, set: { newValue in
                            store.dispatch(.updateTextList(newValue, text.id))
                        }),
                        style: .normal(isIcon: store.state.recommendTexts.count > 1),
                        placeholder: "메뉴 이름",
                        isError: .constant(false)
                    ) {
                        store.dispatch(.deleteTextList(text))
                    }
                }
                if store.state.recommendTexts.count < 3 {
                    plusButton
                }
            }
        }
    }
    
    private var dropDownView: some View {
        VStack(spacing: 0) {
            ForEach(store.state.searchedPlaces, id: \.id) { place in
                PlaceInfoCell(placeInfo: place, placeInfoType: .listCell)
                    .onTapGesture {
                        store.dispatch(.didTapPlaceInfoCell(place))
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
            store.dispatch(.didTapRecommendPlusButton)
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
        .disabled(store.state.isDisablePlusButton)
    }
    
    private var nextButton: some View {
        SpoonyButton(
            style: .primary,
            size: .xlarge,
            title: "다음",
            disabled: Binding(
                get: {
                    store.state.isDisableStartButton
                }, set: { newValue in
                    store.dispatch(.updateButtonState(newValue, .start))
                }
            )
        ) {
            store.dispatch(.didTapNextButton(.start))
        }
        .padding(.bottom, 20)
        .padding(.top, 61)
        .overlay(alignment: .top) {
            ToolTipView()
                .padding(.top, 5)
                .opacity(store.state.isToolTipPresented ? 1 : 0)
                .task {
                    do {
                        try await Task.sleep(for: .seconds(3))
                        store.dispatch(.updateToolTipState)
                    } catch {
                        
                    }
                    
                }
        }
    }
}

#Preview {
    InfoStepView(store: .init(navigationManager: .init()))
}
