//
//  Flight.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct Flight: Sendable, Identifiable {
    let id: String
    let lastUpdated: Date
    let status: String
    
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let heading: Double
    let horizontalSpeed: Double
    
    let departureIata: String
    let arrivalIata: String
    let departureDate: Date?
    let arrivalDate: Date?
    
    let departureTimeZoneId: String?
    let arrivalTimeZoneId: String?
}
