//
//  FlightInterpolationService.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import CoreLocation

struct FlightInterpolationService {
    
    /// Calculates the estimated current position of the flight based on elapsed time and speed.
    func interpolatePosition(for flight: Flight) -> Flight {
        let timeElapsed = Date().timeIntervalSince(flight.lastUpdated)
        
        // If data is very fresh (less than 5 seconds), return as is
        if timeElapsed < 5 { return flight }
        
        // Convert speed from km/h (standard API unit) to m/s
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
            arrivalDate: flight.arrivalDate
        )
    }
    
    private func calculateNewCoordinate(from coordinate: CLLocationCoordinate2D, distanceMeters: Double, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius: Double = 6371000
        let angularDistance = distanceMeters / earthRadius
        let bearingRadians = bearing * .pi / 180
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(angularDistance) * cos(lat1), cos(angularDistance) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(
            latitude: lat2 * 180 / .pi,
            longitude: lon2 * 180 / .pi
        )
    }
}
