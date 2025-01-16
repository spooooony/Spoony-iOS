//
//  InfoStepView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/16/25.
//

import SwiftUI

struct InfoStepView: View {
    @ObservedObject var store: RegisterStore
    @State var isDropDown: Bool = false {
        didSet {
            print(isDropDown)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
            
            placeSection
                
            categorySection
            
            recommendSection
                            
        }
        .overlay(alignment: .top) {
            if isDropDown {
                dropDownView
                    .padding(.top, 171)
            }
        }
    }
}

extension InfoStepView {
    private var titleSection: some View {
        Text("나의 찐맛집을 등록해볼까요?")
            .font(.title2b)
            .foregroundStyle(.spoonBlack)
            .padding(.vertical, 32)
    }
    
    private var placeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("장소명을 알려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            SpoonyTextField(text: $store.text, style: .icon, placeholder: "어떤 장소를 한 입 줄까요?")
                .onSubmit {
                    isDropDown = true
                }
        }
        .padding(.bottom, 40)
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리를 골라주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            IconChip(title: "한식", foodType: .american, chipType: .large, color: .gray600)
        }
        .padding(.bottom, 40)
    }
    
    private var recommendSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("추천 메뉴를 알려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 12)
            SpoonyTextField(text: $store.text, style: .normal(isIcon: false), placeholder: "메뉴 이름")
        }
    }
    
    private var dropDownView: some View {
        List {
            dropDownCell
            dropDownCell
            dropDownCell
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .frame(width: 335.adjusted, height: 189.adjustedH)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray100, lineWidth: 1)
                .background(.white)
        )
    }
    
    private var dropDownCell: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(.icPinGray900)
                .resizable()
                .frame(width: 20.adjusted, height: 20.adjustedH)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("신룽푸마라탕 고속터미널점")
                    .font(.body2b)
                    .foregroundStyle(.spoonBlack)
                Text("서울 서초구 신반포로 194 지하 1층")
                    .font(.caption1m)
                    .foregroundStyle(.gray500)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
    }
}

#Preview {
    InfoStepView(store: .init())
}
