//
//  FlightDetailView.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI
import Combine
import MapKit

struct FlightDetailView: View {
    @ObservedObject var viewModel: FlightTrackerViewModel

    @State private var flight: Flight
    @State private var images: FlightImages?
    
    let onDelete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition
    @State private var pulseAnimation = false
    
    // MARK: - Init
    
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
            _position = State(initialValue: .camera(
                MapCamera(centerCoordinate: center, distance: 100_000, heading: flight.heading)
            ))
        }
    }
    
    // MARK: - Computed
    
    private var statusColor: Color {
        let status = flight.status.lowercased()
        if status.contains("active") || status.contains("en-route") { return .green }
        if status.contains("landed") { return .gray }
        if status.contains("delayed") { return .red }
        return .orange
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

    
    // MARK: - Body
    
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
    
    // MARK: - Map
    
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
                .mapControls {
                    MapCompass().hidden()
                }
                
            } else {
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
    
    // MARK: - Header
    
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
    
    // MARK: - Sheet
    
    private var sheet: some View {
        ZStack {
            Color.black
            
            ScrollView {
                VStack(spacing: 24) {
                    heroCard
                    
                    Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                        GridRow {
                            InfoBox(
                                title: "Status",
                                value: flight.status.capitalized,
                                color: statusColor
                            )
                            
                            InfoBox(
                                title: "Aircraft",
                                value: flight.id,
                                color: .white
                            )
                        }
                        GridRow {
                            InfoBox(
                                title: "Departs",
                                value: formatTime(
                                    flight.departureDate,
                                    timeZoneId: flight.departureTimeZoneId
                                ),
                                color: .white
                            )
                            InfoBox(
                                title: "Arrives",
                                value: formatTime(
                                    flight.arrivalDate,
                                    timeZoneId: flight.arrivalTimeZoneId
                                ),
                                color: .white
                            )
                        }
                        GridRow {
                            InfoBox(
                                title: "Altitude",
                                value: "\(Int(flight.altitude)) m",
                                color: .white
                            )
                            InfoBox(
                                title: "Speed",
                                value: "\(Int(flight.horizontalSpeed)) km/h",
                                color: .white
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                .padding(.bottom, 2)
            }
        }
    }
    
    // MARK: - Hero
    
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
                        .font(.system(size: 40,
                                      weight: .black,
                                      design: .rounded))
                        .foregroundStyle(.white)
                    Text(
                        flight.departureDate?
                            .formatted(date: .abbreviated, time: .omitted)
                        ?? "Origin"
                    )
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
                        .font(.system(size: 40,
                                      weight: .black,
                                      design: .rounded))
                        .foregroundStyle(.white)
                    Text(
                        flight.arrivalDate?
                            .formatted(date: .abbreviated, time: .omitted)
                        ?? "Destination"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }
    
    // MARK: - Helpers
    
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

// MARK: - InfoBox

struct InfoBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.gray.opacity(0.8))
                .textCase(.uppercase)
                .tracking(1)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
