//
//  FlightEntity.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import SwiftData

@Model
final class FlightEntity {
    @Attribute(.unique) var flightIata: String
    var lastUpdated: Date
    var status: String
    
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var heading: Double
    var horizontalSpeed: Double
    
    var departureIata: String
    var arrivalIata: String
    var departureDate: Date?
    var arrivalDate: Date?

    init(
        flightIata: String,
        lastUpdated: Date,
        status: String,
        latitude: Double,
        longitude: Double,
        altitude: Double,
        heading: Double,
        horizontalSpeed: Double,
        departureIata: String,
        arrivalIata: String,
        departureDate: Date?,
        arrivalDate: Date?
    ) {
        self.flightIata = flightIata
        self.lastUpdated = lastUpdated
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.heading = heading
        self.horizontalSpeed = horizontalSpeed
        self.departureIata = departureIata
        self.arrivalIata = arrivalIata
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
    }
}
