//
//  FilteringBottomSheet.swift
//  Spoony-iOS
//
//  Created by 최주리 on 4/25/25.
//

import SwiftUI

struct FilteringBottomSheet: View {
    // TODO: 스크롤에 따라 title 선택되도록...
    @Namespace private var namespace
    
    let filters: FilterInfo = .init(
        categories: CategoryChip.mock(),
        locations: Region.mock()
    )
    @Binding var isPresented: Bool
    @Binding var selectedFilter: SelectedFilterInfo
    @Binding var currentFilter: Int
    
    @State private var tempFilter: SelectedFilterInfo = .init()
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                headerView
                segmentView(proxy)
                    .padding(.horizontal, -20)
                ScrollView {
                    VStack {
                        ForEach(FilterType.allCases, id: \.self) { type in
                            filterView(type)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                
                SpoonyButton(
                    style: .primary,
                    size: .xlarge,
                    title: "필터 적용하기",
                    disabled: .constant(false)
                ) {
                    selectedFilter = tempFilter
                    isPresented = false
                }
                .padding(.top, 24)
                .padding(.bottom, 22)
            }
            .padding(.horizontal, 20)
            .task {
                withAnimation {
                    proxy.scrollTo(FilterType.allCases[currentFilter], anchor: .top)
                }
            }
        }
        .onAppear {
            tempFilter = selectedFilter
        }
    }
}

extension FilteringBottomSheet {
    private var headerView: some View {
        HStack(spacing: 5) {
            Text("필터")
                .customFont(.body1b)
                .foregroundStyle(.gray900)
            Text("필터 초기화")
                .underline()
                .customFont(.caption1m)
                .foregroundStyle(.gray400)
                .padding(.horizontal, 8)
                .padding(.vertical, 3.5)
                .onTapGesture {
                    tempFilter = .init()
                }
            Spacer()
            Image(.icCloseGray400)
                .onTapGesture {
                    isPresented = false
                }
        }
        .padding(.top, 12.adjustedH)
    }
    
    private func segmentView(_ proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(FilterType.allCases.indices, id: \.self) { index in
                    VStack(spacing: 7.adjustedH) {
                        Text(FilterType.allCases[index].title)
                            .font(.body2b)
                            .foregroundColor(currentFilter == index ? .main400 : .gray400)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    currentFilter = index
                                    proxy.scrollTo(FilterType.allCases[index])
                                }
                            }
                        
                        Rectangle()
                            .fill(.main400)
                            .frame(width: 50.adjusted, height: 2.adjustedH)
                            .isHidden(currentFilter != index)
                            .matchedGeometryEffect(id: "underline", in: namespace)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: currentFilter)
            
            Divider()
                .background(.gray200)
        }
        .padding(.top, 10.5)
    }
    
    private func filterView(_ type: FilterType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.title)
                .customFont(.body2sb)
                .foregroundStyle(.gray900)
            ChipsContainerViewForFilter(
                selectedItem: binding(type),
                items: filters.items(type)
            )
        }
        .id(type)
        .padding(.top, 24)
    }
    
    private func binding(_ type: FilterType) -> Binding<[FilterItem]> {
        switch type {
        case .local:
            return $tempFilter.selectedLocal
        case .category:
            return $tempFilter.selectedCategories
        case .location:
            return $tempFilter.selectedLocations
        case .age:
            return $tempFilter.selectedAges
        }
    }
}
