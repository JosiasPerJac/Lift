//
//  FlightMapper.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

enum FlightMapper {
    static func mapToEntity(dto: AviationStackFlight) -> FlightEntity? {
        guard let flightIata = dto.flight.iata else { return nil }
        
        return FlightEntity(
            flightIata: flightIata,
            lastUpdated: dto.live?.updated ?? Date(),
            status: dto.flightStatus ?? "unknown",
            latitude: dto.live?.latitude ?? 0.0,
            longitude: dto.live?.longitude ?? 0.0,
            altitude: dto.live?.altitude ?? 0.0,
            heading: dto.live?.direction ?? 0.0,
            horizontalSpeed: dto.live?.speedHorizontal ?? 0.0,
            departureIata: dto.departure.iata ?? "",
            arrivalIata: dto.arrival.iata ?? "",
            departureDate: dto.departure.scheduled,
            arrivalDate: dto.arrival.scheduled
        )
    }
    
    static func updateEntity(_ entity: FlightEntity, with dto: AviationStackFlight) {
        entity.lastUpdated = dto.live?.updated ?? Date()
        entity.status = dto.flightStatus ?? entity.status
        entity.latitude = dto.live?.latitude ?? entity.latitude
        entity.longitude = dto.live?.longitude ?? entity.longitude
        entity.altitude = dto.live?.altitude ?? entity.altitude
        entity.heading = dto.live?.direction ?? entity.heading
        entity.horizontalSpeed = dto.live?.speedHorizontal ?? entity.horizontalSpeed
    }
    
    static func mapToDomain(entity: FlightEntity) -> Flight {
        return Flight(
            id: entity.flightIata,
            lastUpdated: entity.lastUpdated,
            status: entity.status,
            latitude: entity.latitude,
            longitude: entity.longitude,
            altitude: entity.altitude,
            heading: entity.heading,
            horizontalSpeed: entity.horizontalSpeed,
            departureIata: entity.departureIata,
            arrivalIata: entity.arrivalIata,
            departureDate: entity.departureDate,
            arrivalDate: entity.arrivalDate
        )
    }
}
