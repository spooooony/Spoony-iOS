//
//  ChipsContainerView.swift
//  Spoony-iOS
//
//  Created by 최안용 on 1/17/25.
//

import SwiftUI

struct ChipsContainerView: View {
    @State var totalHeight: CGFloat
    @Binding var selectedItem: [CategoryChip]
    let verticalSpacing: CGFloat
    let horizontalSpacing: CGFloat
    let items: [CategoryChip]
    var sortedItems: [CategoryChip] {
        items.sorted { $0.id < $1.id }
    }
    
    init(
        totalHeight: CGFloat = .zero,
        selectedItem: Binding<[CategoryChip]>,
        verticalSpacing: CGFloat = 8,
        horizontalSpacing: CGFloat = 6,
        items: [CategoryChip]
    ) {
        self.totalHeight = totalHeight
        self._selectedItem = selectedItem
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.items = items
    }
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geomety in
            ZStack(alignment: .topLeading) {
                ForEach(self.sortedItems, id: \.title) { item in
                    CategoryChipsView(category: item, isSelected: item == selectedItem.first)
                        .id(item.title)
                        .alignmentGuide(.leading) { view in
                            if abs(width - view.width) > geomety.size.width {
                                width = 0
                                height -= view.height
                                height -= verticalSpacing
                            }
                            
                            let result = width
                            
                            if item == sortedItems.last {
                                width = 0
                            } else {
                                width -= view.width
                                width -= horizontalSpacing
                            }
                            
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            
                            if item == sortedItems.last {
                                height = 0
                            }
                            
                            return result
                        }
                        .onTapGesture {
                            if selectedItem.isEmpty {
                                selectedItem.append(item)
                            } else {
                                selectedItem.removeLast()
                                selectedItem.append(item)
                            }
                        }
                }
            }
            .background(
                GeometryReader { geomety in
                    Color.clear
                        .onAppear {
                            self.totalHeight = geomety.size.height
                        }
                }
            )
        }
        .frame(height: totalHeight.adjustedH)
    }
}
