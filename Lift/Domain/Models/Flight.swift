//
//  Flight.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// The core domain entity representing a specific flight.
///
/// This structure aggregates all essential data regarding a flight's status,
/// live telemetry, and route information. It serves as the primary data model
/// passed between the Domain, Data, and Presentation layers.
struct Flight: Sendable, Identifiable {
    
    /// The unique identifier for the flight.
    let id: String
    
    /// The timestamp indicating when the data was last fetched or updated.
    ///
    /// This property is critical for the caching strategy to determine if
    /// a fresh API request to AirLabs is necessary.
    let lastUpdated: Date
    
    /// The current operational status of the flight (e.g., "en-route", "landed", "scheduled").
    let status: String
    
    /// The current latitude of the aircraft.
    let latitude: Double
    
    /// The current longitude of the aircraft.
    let longitude: Double
    
    /// The current altitude of the aircraft in meters/feet.
    let altitude: Double
    
    /// The direction the aircraft is pointing, expressed in degrees.
    let heading: Double
    
    /// The horizontal speed of the aircraft.
    let horizontalSpeed: Double
    
    /// The IATA code of the departure airport.
    let departureIata: String
    
    /// The IATA code of the arrival airport.
    let arrivalIata: String
    
    /// The scheduled or actual departure date and time.
    let departureDate: Date?
    
    /// The scheduled or estimated arrival date and time.
    let arrivalDate: Date?
    
    /// The terminal identifier at the departure airport.
    let departureTerminal: String?
    
    /// The gate identifier at the departure airport.
    let departureGate: String?
    
    /// The terminal identifier at the arrival airport.
    let arrivalTerminal: String?
    
    /// The gate identifier at the arrival airport.
    let arrivalGate: String?
    
    /// The time zone identifier for the departure location.
    let departureTimeZoneId: String?
    
    /// The time zone identifier for the arrival location.
    let arrivalTimeZoneId: String?
}
