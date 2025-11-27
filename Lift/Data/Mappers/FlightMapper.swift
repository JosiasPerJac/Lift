//
//  FlightMapper.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

enum FlightMapper {

    private static func normalizedStatus(from dto: AirLabsFlight) -> String {
        let raw = dto.status?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date().timeIntervalSince1970

        if let depTs = dto.depTimeTs, depTs > now {
            return "scheduled"
        }
        return (raw?.isEmpty == false) ? raw! : "unknown"
    }

    static func mapToEntity(dto: AirLabsFlight) -> FlightEntity? {
        guard let flightIata = dto.flightIata else { return nil }

        return FlightEntity(
            flightIata: flightIata,
            lastUpdated: dto.updated.map(Date.init(timeIntervalSince1970:)) ?? Date(),
            status: normalizedStatus(from: dto),
            latitude: dto.lat ?? 0,
            longitude: dto.lng ?? 0,
            altitude: dto.alt ?? 0,
            heading: dto.dir ?? 0,
            horizontalSpeed: dto.speed ?? 0,
            departureIata: dto.depIata ?? "",
            arrivalIata: dto.arrIata ?? "",
            departureDate: dto.depTimeTs.map(Date.init(timeIntervalSince1970:)),
            arrivalDate: dto.arrTimeTs.map(Date.init(timeIntervalSince1970:)),
            departureTerminal: dto.depTerminal,
            departureGate: dto.depGate,
            arrivalTerminal: dto.arrTerminal,
            arrivalGate: dto.arrGate
        )
    }

    static func updateEntity(_ entity: FlightEntity, with dto: AirLabsFlight) {
        if let updated = dto.updated {
            entity.lastUpdated = Date(timeIntervalSince1970: updated)
        }
        entity.status = normalizedStatus(from: dto)
        entity.latitude = dto.lat ?? entity.latitude
        entity.longitude = dto.lng ?? entity.longitude
        entity.altitude = dto.alt ?? entity.altitude
        entity.heading = dto.dir ?? entity.heading
        entity.horizontalSpeed = dto.speed ?? entity.horizontalSpeed
        
        if let dep = dto.depIata { entity.departureIata = dep }
        if let arr = dto.arrIata { entity.arrivalIata = arr }
        if let depTs = dto.depTimeTs { entity.departureDate = Date(timeIntervalSince1970: depTs) }
        if let arrTs = dto.arrTimeTs { entity.arrivalDate = Date(timeIntervalSince1970: arrTs) }
        
        entity.departureTerminal = dto.depTerminal
        entity.departureGate = dto.depGate
        entity.arrivalTerminal = dto.arrTerminal
        entity.arrivalGate = dto.arrGate
    }

    static func mapToDomain(entity: FlightEntity) -> Flight {
        Flight(
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
            arrivalDate: entity.arrivalDate,
            departureTerminal: entity.departureTerminal,
            departureGate: entity.departureGate,
            arrivalTerminal: entity.arrivalTerminal,
            arrivalGate: entity.arrivalGate,
            departureTimeZoneId: entity.departureTimeZoneId,
            arrivalTimeZoneId: entity.arrivalTimeZoneId
        )
    }
}
