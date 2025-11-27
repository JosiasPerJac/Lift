//
//  PassportView.swift
//  Lift
//
//  Created by Josias Pérez on 25/11/25.
//

import SwiftUI
import MapKit
import SwiftData

struct PassportView: View {
    @Query(sort: \FlightEntity.departureDate, order: .forward) private var savedFlights: [FlightEntity]
    @Environment(\.dismiss) var dismiss
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                
                ZStack {
                    RadialGradient(
                        colors: [Color(red: 0.4, green: 0.1, blue: 0.8).opacity(0.4), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: geometry.size.width * 1.5
                    )
                    
                    RadialGradient(
                        colors: [Color(red: 0.1, green: 0.6, blue: 0.9).opacity(0.2), .clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: geometry.size.width * 1.2
                    )
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    mapHeader(height: geometry.size.height * 0.5)
                        .mask(
                            LinearGradient(
                                colors: [.black, .black, .black.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    passportCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.white.opacity(0.6), Color.white.opacity(0.2))
                        .padding()
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private func mapHeader(height: CGFloat) -> some View {
        Map {
            ForEach(savedFlights) { flight in
                Annotation(flight.flightIata, coordinate: CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)) {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 6, height: 6)
                        .shadow(color: .cyan, radius: 6)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                }
            }
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .frame(height: height)
        .overlay(alignment: .top) {
            HStack(spacing: 12) {
                ForEach(0..<8) { _ in
                    Image(systemName: "airplane")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                        .rotationEffect(.degrees(90))
                }
                Text("LIFT AIRSPACE")
                    .font(.caption2.weight(.black))
                    .tracking(2)
                    .foregroundStyle(.cyan.opacity(0.6))
                ForEach(0..<8) { _ in
                    Image(systemName: "airplane")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.2))
                        .rotationEffect(.degrees(90))
                }
            }
            .padding(.top, 60)
        }
    }

    private var passportCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("2025 LIFT PASSPORT")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundStyle(.white)
                        .tracking(1)
                        .shadow(color: .purple.opacity(0.8), radius: 12)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "globe.americas.fill")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        Text("GLOBAL ACCESS • UNLIMITED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.6))
                            .tracking(1)
                    }
                }
                Spacer()
                
                Image(systemName: "airplane.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 8)
            }
            .padding(.bottom, 8)
            
            Divider()
                .background(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.5), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                statItem(label: "FLIGHTS", value: "\(savedFlights.count)")
                statItem(label: "DISTANCE", value: calculateTotalDistance())
                statItem(label: "FLIGHT TIME", value: calculateTotalTime())
                statItem(label: "AIRLINES", value: "\(calculateUniqueAirlines())")
            }
            
            VStack(spacing: 4) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .purple.opacity(0.6), .cyan.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                HStack {
                    Text("LIFT<<<<MEMBER<<<<\(Date().formatted(.iso8601.year()))<<<<")
                    Spacer()
                    Text("ISSUED<<WORLDWIDE")
                }
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.top, 10)
        }
        .padding(24)
        .background(
            ZStack {
                Color.black.opacity(0.6)
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .cyan.opacity(0.3),
                            .purple,
                            .blue,
                            .cyan,
                            .purple.opacity(0.3)
                        ]),
                        center: .center,
                        startAngle: .degrees(isAnimating ? 360 : 0),
                        endAngle: .degrees(isAnimating ? 720 : 360)
                    ),
                    lineWidth: 2
                )
        )
        .shadow(
            color: isAnimating ? .purple.opacity(0.5) : .cyan.opacity(0.3),
            radius: isAnimating ? 20 : 10,
            x: 0,
            y: 0
        )
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.5))
            
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .white.opacity(0.6), radius: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func calculateTotalTime() -> String {
        var totalInterval: TimeInterval = 0
        
        for flight in savedFlights {
            if let start = flight.departureDate, let end = flight.arrivalDate {
                totalInterval += end.timeIntervalSince(start)
            }
        }
        
        let hours = Int(totalInterval) / 3600
        let minutes = (Int(totalInterval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func calculateTotalDistance() -> String {
        var totalHours: Double = 0
        
        for flight in savedFlights {
            if let start = flight.departureDate, let end = flight.arrivalDate {
                totalHours += end.timeIntervalSince(start) / 3600
            }
        }
        
        let distance = Int(totalHours * 500)
        return "\(distance.formatted())mi"
    }
    
    private func calculateUniqueAirlines() -> Int {
        let codes = savedFlights.map { String($0.flightIata.prefix(2)) }
        return Set(codes).count
    }
}

#Preview {
    PassportView()
}
