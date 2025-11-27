//
//  FlightDetailView.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI
import Combine
import MapKit

/// The detailed view displaying comprehensive information about a specific flight.
///
/// This view features a dynamic 3D map that tracks the flight's live position (interpolated),
/// along with departure/arrival times, terminal info, and aircraft telemetry.
struct FlightDetailView: View {
    @ObservedObject var viewModel: FlightTrackerViewModel

    @State private var flight: Flight
    @State private var images: FlightImages?
    
    let onDelete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    /// Controls the camera perspective of the Map view.
    @State private var position: MapCameraPosition
    
    /// Animation state for the "pulsing" radar effect around the plane.
    @State private var pulseAnimation = false
    
    /// Initializes the view and sets the initial map camera based on the flight's location.
    init(
        flight: Flight,
        images: FlightImages? = nil,
        onDelete: (() -> Void)? = nil,
        viewModel: FlightTrackerViewModel
    ) {
        self._flight = State(initialValue: flight)
        self._images = State(initialValue: images)
        self.onDelete = onDelete
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        
        if flight.latitude == 0 && flight.longitude == 0 {
            _position = State(initialValue: .automatic)
        } else {
            let center = CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)
            // Sets a camera 100km above the plane, matching its heading
            _position = State(initialValue: .camera(
                MapCamera(centerCoordinate: center, distance: 100_000, heading: flight.heading)
            ))
        }
    }
    
    /// Determines the semantic color based on flight status (Active/Landed/Delayed).
    private var statusColor: Color {
        let status = flight.status.lowercased()
        if status.contains("active") || status.contains("en-route") { return .green }
        if status.contains("landed") { return .gray }
        if status.contains("delayed") { return .red }
        return .green
    }
    
    private var hasValidCoordinates: Bool {
        flight.latitude != 0 && flight.longitude != 0
    }
    
    private var isLanded: Bool {
        let s = flight.status.lowercased()
        return s.contains("landed") || s.contains("arrived")
    }

    private var isScheduled: Bool {
        flight.status.lowercased().contains("scheduled")
    }

    var body: some View {
        GeometryReader { geometry in
            let desiredSheetHeight: CGFloat = 430
            let mapHeight = max(geometry.size.height * 0.42, geometry.size.height - desiredSheetHeight)

            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack {
                        mapLayer
                            .ignoresSafeArea(edges: .top)

                        VStack {
                            HStack { headerCard }
                                .padding(.top,
                                         (geometry.safeAreaInsets.top > 0
                                          ? geometry.safeAreaInsets.top + 16
                                          : 68))
                                .padding(.horizontal, 18)
                            Spacer()
                        }
                    }
                    .frame(height: mapHeight)

                    sheet
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        // Listen for live updates from the ViewModel (Interpolation Service)
        .onReceive(viewModel.$currentFlight.compactMap { $0 }) { updated in
            guard updated.id == flight.id else { return }
            flight = updated
            updateCamera(with: updated)
        }
        .onReceive(viewModel.$flightImages) { newImages in
            guard let newImages else { return }
            images = newImages
        }
    }
    
    /// The map view showing the live aircraft position or a placeholder state.
    private var mapLayer: some View {
        ZStack {
            if hasValidCoordinates {
                Map(position: $position) {
                    Annotation(
                        flight.id,
                        coordinate: CLLocationCoordinate2D(
                            latitude: flight.latitude,
                            longitude: flight.longitude
                        )
                    ) {
                        ZStack {
                            // Pulsing Radar Effect
                            Circle()
                                .stroke(statusColor.opacity(0.5), lineWidth: 1)
                                .frame(
                                    width: pulseAnimation ? 60 : 0,
                                    height: pulseAnimation ? 60 : 0
                                )
                                .opacity(pulseAnimation ? 0 : 1)
                                .animation(
                                    .easeOut(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: pulseAnimation
                                )
                            
                            Image(systemName: "airplane")
                                .font(.largeTitle)
                                .foregroundStyle(statusColor)
                                .rotationEffect(.degrees(flight.heading - 90))
                                .shadow(color: .black, radius: 2)
                        }
                        .onAppear { pulseAnimation = true }
                    }
                }
                .mapStyle(.hybrid(elevation: .realistic))
                .mapControlVisibility(.hidden)
                .environment(\.colorScheme, .dark)
                
            } else {
                // Placeholder for flights without coordinates (e.g., Scheduled)
                ZStack {
                    Color(red: 14/255, green: 16/255, blue: 28/255)

                    VStack(spacing: 8) {
                        Image(systemName: isLanded ? "airplane.arrival" : (isScheduled ? "calendar" : "wifi.slash"))
                            .font(.system(size: 44))
                            .foregroundStyle(.white.opacity(0.7))

                        Text(isLanded ? "Flight Landed" : (isScheduled ? "Flight Scheduled" : "Live position unavailable"))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
        }
    }
    
    private var headerCard: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "arrow.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(flight.id)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text("\(flight.departureIata) → \(flight.arrivalIata)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            if let onDelete {
                Button {
                    onDelete()
                    dismiss()
                } label: {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
    }
    
    private var sheet: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05)
            
            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    
                    VStack(spacing: 1) {
                        LegInfoRow(
                            airportCode: flight.departureIata,
                            time: formatTime(flight.departureDate, timeZoneId: flight.departureTimeZoneId),
                            timeLabel: "Scheduled",
                            terminal: flight.departureTerminal ?? "-",
                            gate: flight.departureGate ?? "-",
                            isDeparture: true,
                            statusColor: statusColor
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        LegInfoRow(
                            airportCode: flight.arrivalIata,
                            time: formatTime(flight.arrivalDate, timeZoneId: flight.arrivalTimeZoneId),
                            timeLabel: "Scheduled",
                            terminal: flight.arrivalTerminal ?? "-",
                            gate: flight.arrivalGate ?? "-",
                            isDeparture: false,
                            statusColor: statusColor
                        )
                    }
                    .background(Color(red: 0.11, green: 0.11, blue: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    
                    HStack(spacing: 16) {
                        DarkStatBox(
                            icon: "airplane",
                            title: "Aircraft",
                            value: "B787-9"
                        )
                        
                        DarkStatBox(
                            icon: "speedometer",
                            title: "Speed",
                            value: "\(Int(flight.horizontalSpeed)) km/h"
                        )
                        
                        DarkStatBox(
                            icon: "arrow.up.to.line",
                            title: "Altitude",
                            value: "\(Int(flight.altitude)) m"
                        )
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var heroCard: some View {
        ZStack {
            if let url = images?.airport {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .overlay(Color.black.opacity(0.6))
                    } else {
                        Color.black
                    }
                }
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 24/255, green: 26/255, blue: 36/255),
                        Color(red: 18/255, green: 20/255, blue: 30/255)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(flight.departureIata)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(flight.departureDate?.formatted(date: .abbreviated, time: .omitted) ?? "Origin")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "airplane")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                VStack(alignment: .trailing) {
                    Text(flight.arrivalIata)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text(flight.arrivalDate?.formatted(date: .abbreviated, time: .omitted) ?? "Destination")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// Updates the MapCamera position when new flight data arrives (interpolation).
    private func updateCamera(with flight: Flight) {
        guard flight.latitude != 0 && flight.longitude != 0 else { return }
        let center = CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)
        position = .camera(
            MapCamera(centerCoordinate: center, distance: 100_000, heading: flight.heading)
        )
    }
    
    private func formatTime(_ date: Date?, timeZoneId: String?) -> String {
        guard let date else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        if let timeZoneId, let timeZone = TimeZone(identifier: timeZoneId) {
            formatter.timeZone = timeZone
        }
        return formatter.string(from: date)
    }
}

// MARK: - Components

/// A reusable row component displaying departure/arrival details (Terminal, Gate, Time).
struct LegInfoRow: View {
    let airportCode: String
    let time: String
    let timeLabel: String
    let terminal: String
    let gate: String
    let isDeparture: Bool
    let statusColor: Color
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: isDeparture ? "airplane.departure" : "airplane.arrival")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(airportCode)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
                
                Text(time)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(isDeparture ? statusColor : .white)
                
                Text(timeLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: isDeparture ? "arrow.up.right.square.fill" : "door.left.hand.open")
                        .font(.caption2)
                        .foregroundStyle(.black)
                    Text(terminal == "-" ? "T-" : "T\(terminal)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 1.0, green: 0.8, blue: 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                HStack(spacing: 4) {
                    Image(systemName: "door.left.hand.open")
                        .font(.caption2)
                        .foregroundStyle(.black)
                    Text(gate == "-" ? "G-" : gate)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 1.0, green: 0.8, blue: 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
    }
}

/// A dark-themed card displaying a single statistic (Speed, Altitude, Aircraft).
struct DarkStatBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.gray)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.gray)
                    .textCase(.uppercase)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.11, green: 0.11, blue: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
