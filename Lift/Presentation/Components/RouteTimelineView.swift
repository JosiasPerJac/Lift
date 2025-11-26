//
//  RouteTimelineView.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI

struct RouteTimelineView: View {
    let progress: Double
    let statusColor: Color

    @State private var animatedProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let clamped = CGFloat(min(max(progress, 0.0), 1.0))

            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 6, height: 6)

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 3)

                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 6, height: 6)
                }
                .padding(.horizontal, 4)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [statusColor, statusColor.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: width * animatedProgress, height: 3)
                        .clipShape(Capsule())
                        .padding(.leading, 6)
                    Spacer()
                }

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [statusColor.opacity(0.9), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 24
                            )
                        )
                        .frame(width: 32, height: 32)
                        .blur(radius: 1.5)
                        .opacity(0.9)

                    Image(systemName: "airplane")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(0))
                }
                .offset(x: max(min(width * animatedProgress - 18, width - 24), 0))
                .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 3)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    animatedProgress = clamped
                }
            }
            .onChange(of: clamped) { oldValue, newValue in
                guard oldValue != newValue else { return }
                withAnimation(.easeInOut(duration: 0.9)) {
                    animatedProgress = newValue
                }
            }
        }
        .frame(height: 34)
    }
}

