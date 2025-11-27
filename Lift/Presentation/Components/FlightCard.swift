//
//  FlightCard.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI

/// A reusable card component that displays detailed summary information about a flight.
///
/// This view visualizes the flight status, route (Departure -> Arrival), and a progress indicator.
struct FlightCard: View {
    
    /// The domain model containing flight data.
        let flight: Flight
        
        /// Optional closure triggered when the "Track" button is pressed.
        var onAdd: (() -> Void)? = nil
        
        /// Determines whether the flight is already tracked, affecting the button's appearance.
        var isSaved: Bool = false

        /// Calculates the flight completion percentage (0.0 to 1.0).
        ///
        /// This logic derives the progress based on the current time relative to the departure
        /// and arrival times. Returns 1.0 if the flight has landed.
    private var progress: Double {
        let status = flight.status.lowercased()
        if status.contains("landed") || status.contains("arrived") {
            return 1.0
        }

        guard let start = flight.departureDate, let end = flight.arrivalDate else {
            return 0.0
        }

        let totalDuration = end.timeIntervalSince(start)
        let elapsed = Date().timeIntervalSince(start)

        guard totalDuration > 0 else { return 0.0 }

        return min(max(elapsed / totalDuration, 0.0), 1.0)
    }
    
    /// Determines the semantic color based on the flight status.
    ///
    /// - Returns: Green for active, Gray for landed, Red for delayed, Orange for others.
    private var statusColor: Color {
        let status = flight.status.lowercased()
        if status.contains("en-route") { return .green }
        if status.contains("landed") { return .gray }
        if status.contains("delayed") { return .red }
        return .orange
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 34, height: 34)

                        Text(flight.id.prefix(2))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(flight.id)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(flight.lastUpdated, format: .dateTime.day().month().year())
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Spacer()

                if let onAdd, !isSaved {
                    Button(action: onAdd) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Track")
                        }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .foregroundStyle(.black)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(flight.status.capitalized)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.15))
                        )
                        .overlay(
                            Capsule()
                                .stroke(statusColor.opacity(0.4), lineWidth: 1)
                        )
                        .foregroundStyle(statusColor)
                }
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureIata)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if let date = flight.departureDate {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text("--:--")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalIata)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if let date = flight.arrivalDate {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.6))
                    } else {
                        Text("--:--")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }

            RouteTimelineView(progress: progress, statusColor: statusColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 25/255, green: 27/255, blue: 37/255),
                            Color(red: 13/255, green: 15/255, blue: 24/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)
    }
}
