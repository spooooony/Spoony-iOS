//
//  ReviewStepView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI
import PhotosUI

struct ReviewStepView: View {
    @ObservedObject private var store: RegisterStore
    
    init(store: RegisterStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            simpleReviewSection
            detailReviewSection
            pictureUploadSection
            
            SpoonyButton(
                style: .primary,
                size: .xlarge,
                title: "다음",
                disabled: Binding(
                    get: {
                        store.state.isDisableMiddleButton
                    }, set: { newValue in
                        store.dispatch(.updateButtonState(newValue, .middle))
                    }
                )
            ) {
                store.dispatch(.didTapNextButton(.middle))                
            }
            .padding(.bottom, 20)
        }
        .background(.white)
        .onTapGesture {
            hideKeyboard()
        }
        .gesture(DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { value in
                if value.translation.width > 150 {
                    store.dispatch(.movePreviousView)
                }
            }
)
    }
}

extension ReviewStepView {
    private var titleView: some View {
        Text("거의 다 왔어요!")
            .font(.title2b)
            .foregroundStyle(.spoonBlack)
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
    }
    
    private var simpleReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("당신의 맛집을 한 줄로 표현해 주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
            
            SpoonyTextField(
                text: Binding(
                    get: {
                        store.state.simpleText
                    }, set: { newValue in
                        store.dispatch(.updateText(newValue, .simple))
                    }
                ),
                style: .helper,
                placeholder: "장소명 언급은 피해주세요. 우리만의 비밀!",
                isError: Binding(
                    get: {
                        store.state.isSimpleTextError
                    }, set: { newValue in
                        store.dispatch(.updateTextError(newValue, .simple))
                    }
                )
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var detailReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("자세한 후기를 적어주세요")
                    .font(.body1sb)
                    .foregroundStyle(.spoonBlack)
                
                HStack(spacing: 4) {
                    Image(.icRegisterMain400)
                        .resizable()
                        .frame(width: 6.adjusted, height: 6.adjustedH)
                    
                    Text("50자 이상")
                        .font(.caption1m)
                        .foregroundStyle(.main400)
                }
            }
            
            SpoonyTextEditor(
                text: Binding(
                    get: {
                        store.state.detailText
                    }, set: { newValue in
                        store.dispatch(.updateText(newValue, .detail))
                    }
                ),
                style: .review,
                placeholder: "장소명 언급은 피해주세요. 우리만의 비밀!",
                isError: Binding(
                    get: {
                        store.state.isDetailTextError
                    }, set: { newValue in
                        store.dispatch(.updateTextError(newValue, .detail))
                    }
                )
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var pictureUploadSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("음식 사진을 올려주세요")
                .font(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal) {
                HStack {
                    plusButton
                    
                    ForEach(store.state.uploadImages) { image in
                        loadedImageView(image)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
            .gesture(DragGesture().onChanged { _ in })
            
            if store.state.uploadImageErrorState == .error {
                HStack(spacing: 6) {
                    Image(.icErrorRed)
                        .resizable()
                        .frame(width: 16.adjusted, height: 16.adjustedH)
                    Text("사진 업로드는 필수예요")
                        .font(.caption1m)
                        .foregroundStyle(.error400)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var plusButton: some View {
        PhotosPicker(
            selection: Binding(
                get: {
                    store.state.pickerItems
                }, set: { newValue in
                    store.dispatch(.updatePickerItems(newValue))
                    hideKeyboard()
                }
            ),
            maxSelectionCount: store.state.selectableCount,
            matching: .images
        ) {
            VStack(spacing: 4) {
                Image(.icPlusGray400)
                    .resizable()
                    .frame(width: 16.adjusted, height: 16.adjustedH)
                Text("\(store.state.uploadImages.count)/5")
                    .font(.caption1m)
                    .foregroundStyle(.gray400)
            }
            .frame(width: 80.adjusted, height: 80.adjustedH)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .strokeBorder(.gray100)
            }
        }
        .disabled(store.state.uploadImages.count == 5)
    }
    
    private func loadedImageView(_ image: UploadImage) -> some View {
        image.image
            .resizable()
            .scaledToFill()
            .frame(width: 80.adjusted, height: 80.adjustedH)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topTrailing) {
                Button {
                    store.dispatch(.deleteImage(image))
                } label: {
                    Image(.icDeleteFillGray400)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 20.adjusted, height: 20.adjustedH)
                }
                .padding(.top, 4)
                .padding(.trailing, 4.5)
            }
    }
}

#Preview {
    ReviewStepView(store: .init(navigationManager: .init()))
}
