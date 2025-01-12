//
//  CustomBottomSheet.swift
//  SpoonMe
//
//  Created by 이지훈 on 1/12/25.
//

struct CustomBottomSheet<Content: View>: View {
    @StateObject private var viewModel: BottomSheetViewModel
    let content: Content
    @Binding var isPresented: Bool
    
    init(style: BottomSheetStyle, isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._viewModel = StateObject(wrappedValue: BottomSheetViewModel(style: style))
        self._isPresented = isPresented
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if viewModel.model.isPresented {
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray)
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        
                        content
                    }
                    .frame(height: viewModel.model.currentHeight - viewModel.model.dragOffset)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                viewModel.trigger(.drag(translation: value.translation.height))
                            })
                            .onEnded({ value in
                                viewModel.trigger(.endDrag(translation: value.translation.height))
                            })
                    )
                    .transition(.move(edge: .bottom))
                    .offset(y: -geometry.safeAreaInsets.bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: viewModel.model.isPresented)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: viewModel.model.currentHeight)
        .onChange(of: isPresented) { newValue in
            viewModel.trigger(newValue ? .show : .hide)
        }
        .onChange(of: viewModel.model.isPresented) { newValue in
            isPresented = newValue
        }
    }
} 