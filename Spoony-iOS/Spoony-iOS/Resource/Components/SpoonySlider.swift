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
        .padding(.horizontal, 20)
    }
}

extension SpoonySlider {
    private var sliderView: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width - 22.adjusted
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.gray100)
                    .frame(height: 11.adjustedH)
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 11.adjustedH)
                    .background(
                        LinearGradient(
                            gradient: .init(colors: [.main100, .main400, .main400]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 40)
                    )
                    .frame(width: (sliderValue / 100) * totalWidth + 11.adjusted, height: 11.adjustedH)
                
                Image(.icSlider)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22.adjusted, height: 22.adjustedH)
                    .shadow(color: .gray300, radius: 16)
                    .offset(x: (sliderValue / 100) * totalWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let x = value.location.x - 11.adjusted
                                let clampedX = min(max(0, x), totalWidth)
                                sliderValue = round((clampedX / totalWidth) * 100.0)
                            }
                    )
            }
            .onTapGesture(coordinateSpace: .local) { location in
                let x = location.x - 11.adjusted
                let clampedX = min(max(0, x), totalWidth)
                sliderValue = round((clampedX / totalWidth) * 100.0)
            }
            .animation(.smooth, value: sliderValue)
        }
    }
}

#Preview {
    SpoonySlider(.constant(50.0))
}
