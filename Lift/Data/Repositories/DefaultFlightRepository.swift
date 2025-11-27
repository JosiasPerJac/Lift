//
//  DefaultFlightRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import SwiftData

/// The concrete implementation of `FlightRepository` that manages data synchronization.
///
/// This class acts as the "Source of Truth" for flight data. It implements a **Cache-Aside** strategy
/// to minimize requests to the AirLabs API, ensuring the app remains responsive and within
/// API rate limits.
///
/// - Note: Data is persisted locally using **SwiftData**.
final class DefaultFlightRepository: FlightRepository {
    
    /// The networking client for the AirLabs API.
    private let airLabsClient: AirLabsClient
    
    /// The SwiftData context used for database operations.
    private let modelContext: ModelContext
    
    /// The duration (in seconds) for which the local data is considered fresh.
    ///
    /// Currently set to **300 seconds (5 minutes)** to balance data accuracy with API usage.
    private let cacheValidity: TimeInterval = 300
    
    /// Initializes the repository with required dependencies.
    ///
    /// - Parameters:
    ///   - airLabsClient: The networking client.
    ///   - modelContext: The database context.
    init(airLabsClient: AirLabsClient, modelContext: ModelContext) {
        self.airLabsClient = airLabsClient
        self.modelContext = modelContext
    }
    
    /// Fetches flight details using a smart caching strategy.
    ///
    /// 1. Checks the local **SwiftData** storage for the given IATA code.
    /// 2. If the data exists and is younger than `cacheValidity` (5 mins), it returns the local copy.
    /// 3. If data is missing or stale, it fetches fresh data from the **AirLabs API**.
    ///
    /// - Parameter iata: The IATA code of the flight.
    /// - Returns: A domain `Flight` object.
    /// - Throws: An error if both local retrieval and network fetching fail.
    func getFlight(iata: String) async throws -> Flight? {
        if let cachedEntity = fetchLocalEntity(iata: iata), isCacheValid(cachedEntity) {
            return FlightMapper.mapToDomain(entity: cachedEntity)
        }
        return try await fetchRemoteFlight(iata: iata)
    }

    /// Manually saves a flight to the local database.
    ///
    /// - Parameter flight: The domain `Flight` object to persist.
    /// - Throws: An error if the database write operation fails.
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
    
    /// Helper method to retrieve a raw entity from SwiftData.
    private func fetchLocalEntity(iata: String) -> FlightEntity? {
        let descriptor = FetchDescriptor<FlightEntity>(
            predicate: #Predicate { $0.flightIata == iata }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    /// Validates if the cached entity is still fresh.
    ///
    /// - Returns: `true` if the time elapsed since `lastUpdated` is less than `cacheValidity`.
    private func isCacheValid(_ entity: FlightEntity) -> Bool {
        return Date().timeIntervalSince(entity.lastUpdated) < cacheValidity
    }
    
    /// Fetches fresh data from the API and updates the local cache.
    ///
    /// This method handles the logic of either updating an existing SwiftData entity
    /// or inserting a completely new one, ensuring the database stays in sync with the API.
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
