//
//  ForgottenCardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/2/25.
//

//import SwiftUI
//
//struct ForgottenCardStackView: View {
//    @EnvironmentObject var auth: AuthViewModel
//    
//    @ObservedObject var swipeVM: SwipeableCardsViewModel
//    var stack: Stack
//
//    @State private var dragState = CGSize.zero
//    let swipeThreshold: CGFloat = 100.0
//
//    var body: some View {
//        ZStack {
//            ForEach(swipeVM.unswipedForgottenCards.reversed(), id: \.id) { card in
//                let isTopCard = card.id == swipeVM.unswipedForgottenCards.first?.id
//                CardView(
//                    presenter: FlipCardPresenter(),
//                    card: card,
//                    stack: stack,
//                    dragOffset: dragState,
//                    isTopCard: isTopCard,
//                    isSecondCard: false
//                )
//                .gesture(
//                    DragGesture()
//                        .onChanged { gesture in
//                            if isTopCard {
//                                dragState = gesture.translation
//                            }
//                        }
//                        .onEnded { _ in
//                            if abs(dragState.width) > swipeThreshold {
//                                withAnimation(.easeOut(duration: 0.5)) {
//                                    dragState.width = dragState.width > 0 ? 1000 : -1000
//                                }
//
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    swipeVM.removeTopForgottenCard()
//                                    dragState = .zero
//                                }
//                            } else {
//                                withAnimation {
//                                    dragState = .zero
//                                }
//                            }
//                        }
//                )
//            }
//        }
//        .frame(width: 340, height: 524)
//    }
//}
//
//
//#Preview {
//    ForgottenCardStackView()
//        .environmentObject(AuthViewModel())
//}
