//
//  DefaultFlightRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import SwiftData

final class DefaultFlightRepository: FlightRepository {
    private let aviationClient: AviationStackClient
    private let modelContext: ModelContext
    private let cacheValidity: TimeInterval = 300
    
    init(aviationClient: AviationStackClient, modelContext: ModelContext) {
        self.aviationClient = aviationClient
        self.modelContext = modelContext
    }
    
    func getFlight(iata: String) async throws -> Flight? {
        if let cachedEntity = fetchLocalEntity(iata: iata), isCacheValid(cachedEntity) {
            
            return FlightMapper.mapToDomain(entity: cachedEntity)
        }
        return try await fetchRemoteFlight(iata: iata)
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
        let flights = try await aviationClient.fetchFlights(iataCode: iata)
        guard let flightDTO = flights.first else { return nil }
        
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
