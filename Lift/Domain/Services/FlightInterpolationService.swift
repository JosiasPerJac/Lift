//
//  FlightInterpolationService.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import CoreLocation

struct FlightInterpolationService {
    
    func interpolatePosition(for flight: Flight) -> Flight {
        let timeElapsed = Date().timeIntervalSince(flight.lastUpdated)
        
        if timeElapsed < 5 { return flight }
        
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
            lastUpdated: Date(),
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
    
    private func calculateNewCoordinate(from coordinate: CLLocationCoordinate2D, distanceMeters: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius: Double = 6371000
        let angularDistance = distanceMeters / earthRadius
        let bearingRadians = bearing * .pi / 180
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        
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
