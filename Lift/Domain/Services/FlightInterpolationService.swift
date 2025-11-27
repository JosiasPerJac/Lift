//
//  FlightInterpolationService.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import CoreLocation

/// A service responsible for estimating the real-time position of an aircraft.
///
/// Due to the request limits of the AirLabs API (and the static nature of HTTP responses),
/// flight data can become "stale" quickly. This service solves that problem by using
/// **Dead Reckoning** (navigation based on speed and heading) to predict where the
/// aircraft is right now, providing a smooth visual experience on the map.
struct FlightInterpolationService {
    
    /// Calculates the estimated current position of a flight based on its last known telemetry.
    ///
    /// This method applies basic physics: `Distance = Velocity × Time`.
    ///
    /// - Parameter flight: The `Flight` object containing the last known position, speed (km/h), and heading.
    /// - Returns: A new `Flight` instance with updated latitude, longitude, and a refreshed `lastUpdated` timestamp.
    ///
    /// - Note: If less than 5 seconds have passed since the last update, the original flight is returned to avoid unnecessary calculations.
    func interpolatePosition(for flight: Flight) -> Flight {
        let timeElapsed = Date().timeIntervalSince(flight.lastUpdated)
        
        // Avoid micro-updates if the data is very fresh
        if timeElapsed < 5 { return flight }
        
        // Convert speed from km/h to m/s (Factor: 1 km/h = 0.277778 m/s)
        let speedInMetersPerSecond = flight.horizontalSpeed * 0.277778
        let distanceTraveled = speedInMetersPerSecond * timeElapsed
        let currentLocation = CLLocationCoordinate2D(latitude: flight.latitude, longitude: flight.longitude)
        
        let newCoordinate = calculateNewCoordinate(
            from: currentLocation,
            distanceMeters: distanceTraveled,
            bearing: flight.heading
        )
        
        return Flight(
            id: flight.id,
            lastUpdated: Date(), // Update timestamp to current simulation time
            status: flight.status,
            latitude: newCoordinate.latitude,
            longitude: newCoordinate.longitude,
            altitude: flight.altitude,
            heading: flight.heading,
            horizontalSpeed: flight.horizontalSpeed,
            departureIata: flight.departureIata,
            arrivalIata: flight.arrivalIata,
            departureDate: flight.departureDate,
            arrivalDate: flight.arrivalDate,
            departureTerminal: flight.departureTerminal,
            departureGate: flight.departureGate,
            arrivalTerminal: flight.arrivalTerminal,
            arrivalGate: flight.arrivalGate,
            departureTimeZoneId: flight.departureTimeZoneId,
            arrivalTimeZoneId: flight.arrivalTimeZoneId
        )
    }
    
    /// Calculates a destination coordinate given a start point, distance, and bearing.
    ///
    /// This method uses **Spherical Trigonometry** formulas to account for the Earth's curvature.
    /// It treats the Earth as a sphere with a radius of approx. 6,371 km.
    ///
    /// - Parameters:
    ///   - coordinate: The starting `CLLocationCoordinate2D`.
    ///   - distanceMeters: The distance traveled in meters.
    ///   - bearing: The direction of travel in degrees (0° is North).
    /// - Returns: The new `CLLocationCoordinate2D`.
    private func calculateNewCoordinate(from coordinate: CLLocationCoordinate2D, distanceMeters: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius: Double = 6371000
        let angularDistance = distanceMeters / earthRadius
        let bearingRadians = bearing * .pi / 180
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        
        // Formula: Destination point given distance and bearing from start point
        let lat2 = asin(sin(lat1) * cos(angularDistance) +
                        cos(lat1) * sin(angularDistance) * cos(bearingRadians))
        let lon2 = lon1 + atan2(
            sin(bearingRadians) * sin(angularDistance) * cos(lat1),
            cos(angularDistance) - sin(lat1) * sin(lat2)
        )
        
        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
}
