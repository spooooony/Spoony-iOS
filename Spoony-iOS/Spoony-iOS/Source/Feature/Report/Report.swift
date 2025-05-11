//
//  Report.swift
//  Spoony-iOS
//
//  Created by 최주리 on 1/16/25.
//

import SwiftUI

import ComposableArchitecture

struct Report: View {
    @Bindable private var store: StoreOf<ReportFeature>
    private let postId: Int
    
    init(postId: Int, store: StoreOf<ReportFeature>) {
        self.postId = postId
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(
                style: .detail,
                title: "신고하기",
                onBackTapped: {
                    store.send(.routeToExploreScreen)
                }
            )
            Divider()
            ScrollView {
                reportTitle
                reportDescription
                
                SpoonyButton(
                    style: .secondary,
                    size: .xlarge,
                    title: "신고하기",
                    disabled: $store.isError
                ) {
                    hideKeyboard()
                    store.send(.reportPostButtonTapped(postId))
                }
                .padding(.top, !store.state.isError ? 12 : 20)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxHeight: .infinity)
        .background(.white)
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden()
    }
}

extension Report {
    
    // MARK: - Views
    private var reportTitle: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("후기를 신고하는 이유가 무엇인가요?")
                .customFont(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 12)
            
            ForEach(ReportType.allCases, id: \.self) { report in
                radioButton(
                    report: report,
                    isSelected: store.state.selectedReport == report
                )
                .onTapGesture {
                    store.send(.reportReasonButtonTapped(report))
                    hideKeyboard()
                }
            }
        }
        .padding(.top, 31)
        .padding(.horizontal, 20)
    }
    
    private var reportDescription: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("자세한 내용을 적어주세요")
                .customFont(.body1sb)
                .foregroundStyle(.spoonBlack)
                .padding(.bottom, 12.adjustedH)
            
            SpoonyTextEditor(
                text: $store.description,
                style: .report,
                placeholder: "내용을 자세히 적어주시면 신고에 도움이 돼요",
                isError: $store.isError
            )
            
            HStack(alignment: .top, spacing: 10) {
                Image(.icErrorGray300)
                
                Text("스푸니는 철저한 광고 제한 정책과 모니터링을 실시하고 있어요. 부적절한 후기 작성자를 발견하면, 바로 신고해주세요!")
                    .customFont(.caption1m)
                    .foregroundStyle(.gray400)
            }
            .padding(10)
            .frame(width: 335.adjusted, height: 71.adjustedH)
            .background(.gray0, in: RoundedRectangle(cornerRadius: 8))
            .padding(.top, 8)
        }
        .padding(.top, 32)
        .padding(.horizontal, 20)
    }
    
    private func radioButton(report: ReportType, isSelected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(isSelected ? .icRadioOnGray900 : .icRadioOffGray400)
            
            Text(report.title)
                .customFont(.body1m)
                .foregroundStyle(.gray900)
            
            Spacer()
        }
        .frame(height: 42.adjustedH)
    }
}
