//
//  SpoonySlider.swift
//  Spoony-iOS
//
//  Created by 최안용 on 4/15/25.
//

import SwiftUI

struct SpoonySlider: View {
    @Binding var sliderValue: Double
    private var isDisabled: Bool
    private let thumbSize = 22
    
    init(_ sliderValue: Binding<Double>, isDisabled: Bool = false) {
        self._sliderValue = sliderValue
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        VStack(spacing: 10) {
            sliderView
                .frame(height: 22.adjustedH)
                .disabled(isDisabled)
            HStack(spacing: 0) {
                Text("아쉬움")
                Spacer()
                Text("적당함")
                Spacer()
                Text("훌륭함")
            }
            .lineLimit(1)
            .font(.body2m)
            .foregroundStyle(.spoonBlack)
        }
    }
}

extension SpoonySlider {
    private func updateSliderValue(_ inputX: CGFloat, _ totalWidth: CGFloat) {
        let x = inputX - thumbSize.adjusted / 2
        let clampedX = min(max(0, x), totalWidth)
        sliderValue = round((clampedX / totalWidth) * 100.0)
    }
    
    private var sliderView: some View {
        let sliderHeight = 11.adjustedH
        
        return GeometryReader { geo in
            let totalWidth = geo.size.width - thumbSize.adjusted
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.gray100)
                    .frame(height: sliderHeight)
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: sliderHeight)
                    .background(
                        LinearGradient(
                            gradient: .init(colors: [.main100, .main400, .main400]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 40)
                    )
                    .frame(
                        width: (sliderValue / 100) * totalWidth + thumbSize.adjusted / 2,
                        height: sliderHeight
                    )
                
                Image(.icSlider)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbSize.adjusted, height: thumbSize.adjustedH)
                    .shadow(color: .gray300, radius: 16)
                    .offset(x: (sliderValue / 100) * totalWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateSliderValue(value.location.x, totalWidth)
                            }
                    )
            }
            .onTapGesture(coordinateSpace: .local) { location in
                updateSliderValue(location.x, totalWidth)
            }
            .animation(.smooth, value: sliderValue)
        }
    }
}

#Preview {
    SpoonySlider(.constant(50.0))
}
