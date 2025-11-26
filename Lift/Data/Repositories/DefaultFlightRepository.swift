//
//  DefaultFlightRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import SwiftData

final class DefaultFlightRepository: FlightRepository {
    private let airLabsClient: AirLabsClient
    private let modelContext: ModelContext
    private let cacheValidity: TimeInterval = 300
    
    init(airLabsClient: AirLabsClient, modelContext: ModelContext) {
        self.airLabsClient = airLabsClient
        self.modelContext = modelContext
    }
    
    func getFlight(iata: String) async throws -> Flight? {
        if let cachedEntity = fetchLocalEntity(iata: iata), isCacheValid(cachedEntity) {
            return FlightMapper.mapToDomain(entity: cachedEntity)
        }
        return try await fetchRemoteFlight(iata: iata)
    }

    func saveFlight(_ flight: Flight) throws {
        if fetchLocalEntity(iata: flight.id) != nil {
            return
        }

        let newEntity = FlightEntity(
            flightIata: flight.id,
            lastUpdated: Date(),
            status: flight.status,
            latitude: flight.latitude,
            longitude: flight.longitude,
            altitude: flight.altitude,
            heading: flight.heading,
            horizontalSpeed: flight.horizontalSpeed,
            departureIata: flight.departureIata,
            arrivalIata: flight.arrivalIata,
            departureDate: flight.departureDate,
            arrivalDate: flight.arrivalDate
        )

        modelContext.insert(newEntity)
        try modelContext.save()
    }
    
    private func fetchLocalEntity(iata: String) -> FlightEntity? {
        let descriptor = FetchDescriptor<FlightEntity>(
            predicate: #Predicate { $0.flightIata == iata }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func isCacheValid(_ entity: FlightEntity) -> Bool {
        return Date().timeIntervalSince(entity.lastUpdated) < cacheValidity
    }
    
    private func fetchRemoteFlight(iata: String) async throws -> Flight? {
        guard let flightDTO = try await airLabsClient.fetchFlight(iataCode: iata) else {
            return nil
        }
        
        let entityToReturn: FlightEntity
        
        if let existingEntity = fetchLocalEntity(iata: iata) {
            FlightMapper.updateEntity(existingEntity, with: flightDTO)
            entityToReturn = existingEntity
        } else {
            guard let newEntity = FlightMapper.mapToEntity(dto: flightDTO) else { return nil }
            modelContext.insert(newEntity)
            try? modelContext.save()
            entityToReturn = newEntity
        }
        
        return FlightMapper.mapToDomain(entity: entityToReturn)
    }
}
