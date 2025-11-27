//
//  FlightRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// Defines the interface for accessing and managing flight data.
///
/// This protocol acts as a contract between the Domain layer and the Data layer,
/// abstracting the underlying data sources (API or Local Database).
protocol FlightRepository {
    
    /// Fetches flight information based on the IATA code.
    ///
    /// - Parameter iata: The IATA code representing the flight (e.g., "AA123").
    /// - Returns: A `Flight` object if found, or `nil` if no data exists.
    /// - Throws: An error if the retrieval process fails (e.g., network or database errors).
    func getFlight(iata: String) async throws -> Flight?
    
    /// Persists a specific flight entity to the local storage.
    ///
    /// - Parameter flight: The `Flight` model to be saved.
    /// - Throws: An error if the save operation fails.
    func saveFlight(_ flight: Flight) throws
}
