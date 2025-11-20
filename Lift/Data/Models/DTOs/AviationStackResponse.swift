//
//  AviationStackResponse.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct AviationStackResponse: Decodable {
    let data: [AviationStackFlight]
}

struct AviationStackFlight: Decodable {
    let flightDate: String?
    let flightStatus: String?
    let departure: AirportInfo
    let arrival: AirportInfo
    let airline: AirlineInfo
    let flight: FlightInfo
    let live: LiveInfo?

    enum CodingKeys: String, CodingKey {
        case flightDate = "flight_date"
        case flightStatus = "flight_status"
        case departure
        case arrival
        case airline
        case flight
        case live
    }
}

struct AirportInfo: Decodable {
    let airport: String?
    let timezone: String?
    let iata: String?
    let icao: String?
    let terminal: String?
    let gate: String?
    let baggage: String?
    let delay: Int?
    let scheduled: Date?
    let estimated: Date?
    let actual: Date?
    let estimatedRunway: Date?
    let actualRunway: Date?

    enum CodingKeys: String, CodingKey {
        case airport
        case timezone
        case iata
        case icao
        case terminal
        case gate
        case baggage
        case delay
        case scheduled
        case estimated
        case actual
        case estimatedRunway = "estimated_runway"
        case actualRunway = "actual_runway"
    }
}

struct AirlineInfo: Decodable {
    let name: String?
    let iata: String?
    let icao: String?
}

struct FlightInfo: Decodable {
    let number: String?
    let iata: String?
    let icao: String?
}

struct LiveInfo: Decodable {
    let updated: Date?
    let latitude: Double?
    let longitude: Double?
    let altitude: Double?
    let direction: Double?
    let speedHorizontal: Double?
    let speedVertical: Double?
    let isGround: Bool?
    let aircraft: LiveAircraftInfo?

    enum CodingKeys: String, CodingKey {
        case updated
        case latitude
        case longitude
        case altitude
        case direction
        case speedHorizontal = "speed_horizontal"
        case speedVertical = "speed_vertical"
        case isGround = "is_ground"
        case aircraft
    }
}

struct LiveAircraftInfo: Decodable {
    let registration: String?
    let iata: String?
    let icao: String?
    let icao24: String?
}
