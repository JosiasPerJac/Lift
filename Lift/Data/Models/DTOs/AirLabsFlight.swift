//
//  AviationStackResponse.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation


/// Represents the raw JSON structure of a flight returned by the AirLabs API.
struct AirLabsFlight: Decodable {
    let hex: String?
    let regNumber: String?
    let aircraftIcao: String?
    let flag: String?
    
    // Telemetry
    let lat: Double?
    let lng: Double?
    let alt: Double?
    let dir: Double?
    let speed: Double?
    let vSpeed: Double?
    let squawk: String?
    
    // Airline Info
    let airlineIata: String?
    let airlineIcao: String?
    
    // Flight Identifiers
    let flightNumber: String?
    let flightIata: String?
    let flightIcao: String?
    
    // Departure Info
    let depIata: String?
    let depIcao: String?
    let depTerminal: String?
    let depGate: String?
    let depTime: String?
    let depTimeTs: TimeInterval?
    let depTimeUtc: String?
    
    // Arrival Info
    let arrIata: String?
    let arrIcao: String?
    let arrTerminal: String?
    let arrGate: String?
    let arrBaggage: String?
    let arrTime: String?
    let arrTimeTs: TimeInterval?
    let arrTimeUtc: String?
    
    // Schedule & Status
    let duration: Int?
    let delayed: Int?
    let depDelayed: Int?
    let arrDelayed: Int?
    
    let updated: TimeInterval?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case hex
        case regNumber = "reg_number"
        case aircraftIcao = "aircraft_icao"
        case flag
        case lat, lng, alt, dir, speed
        case vSpeed = "v_speed"
        case squawk
        
        case airlineIata = "airline_iata"
        case airlineIcao = "airline_icao"
        
        case flightNumber = "flight_number"
        case flightIata = "flight_iata"
        case flightIcao = "flight_icao"
        
        case depIata = "dep_iata"
        case depIcao = "dep_icao"
        case depTerminal = "dep_terminal"
        case depGate = "dep_gate"
        case depTime = "dep_time"
        case depTimeTs = "dep_time_ts"
        case depTimeUtc = "dep_time_utc"
        
        case arrIata = "arr_iata"
        case arrIcao = "arr_icao"
        case arrTerminal = "arr_terminal"
        case arrGate = "arr_gate"
        case arrBaggage = "arr_baggage"
        case arrTime = "arr_time"
        case arrTimeTs = "arr_time_ts"
        case arrTimeUtc = "arr_time_utc"
        
        case duration
        case delayed
        case depDelayed = "dep_delayed"
        case arrDelayed = "arr_delayed"
        
        case updated
        case status
    }
}

/// A generic wrapper to handle the AirLabs API response envelope.
struct AirLabsEnvelope<T: Decodable>: Decodable {
    let request: AirLabsRequest?
    let response: T?
    let error: AirLabsAPIError?
}

struct AirLabsRequest: Decodable {
    let key: AirLabsKey?
}

struct AirLabsKey: Decodable {
    let id: Int?
}

struct AirLabsAPIError: Decodable {
    let message: String
    let code: String
}
