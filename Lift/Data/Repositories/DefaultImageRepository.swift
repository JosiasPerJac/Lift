//
//  DefaultImageRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// The default implementation of the `ImageRepository` interface.
///
/// This repository is responsible for fetching and aggregating visual assets from the
/// Unsplash API. It optimizes performance by fetching independent resources concurrently.
final class DefaultImageRepository: ImageRepository {
    
    /// The client used to communicate with the Unsplash API.
    private let unsplashClient: UnsplashClient
    
    /// Initializes the repository with a networking client.
    ///
    /// - Parameter unsplashClient: An instance of `UnsplashClient`. Defaults to a new instance.
    init(unsplashClient: UnsplashClient = UnsplashClient()) {
        self.unsplashClient = unsplashClient
    }
    
    /// Retrieves images for the flight's destination airport and the aircraft type.
    ///
    /// This method leverages Swift Concurrency (`async let`) to perform the network requests
    /// for the airport image and the aircraft image in parallel, reducing the total wait time.
    ///
    /// - Parameter flight: The flight entity containing the IATA codes and ID needed for the search queries.
    /// - Returns: A `FlightImages` object containing the URLs.
    /// - Throws: An error if the network request fails.
    func getImages(for flight: Flight) async throws -> FlightImages {
        async let airportPhoto = fetchAirportImage(for: flight)
        async let aircraftPhoto = fetchAircraftImage(for: flight)
        
        return try await FlightImages(airport: airportPhoto, aircraft: aircraftPhoto)
    }
    
    /// Fetches an image URL for the arrival airport.
    ///
    /// - Parameter flight: The flight data used to construct the search query (e.g., "JFK airport").
    /// - Returns: An optional URL if an image is found.
    private func fetchAirportImage(for flight: Flight) async throws -> URL? {
        let query = "\(flight.arrivalIata) airport"
        let photo = try await unsplashClient.fetchSingleImage(query: query)
        return URL(string: photo?.urls.regular ?? "")
    }
    
    /// Fetches an image URL for the specific aircraft.
    ///
    /// - Parameter flight: The flight data used to construct the search query.
    /// - Returns: An optional URL if an image is found.
    private func fetchAircraftImage(for flight: Flight) async throws -> URL? {
        let query = "\(flight.id) aircraft"
        let photo = try await unsplashClient.fetchSingleImage(query: query)
        return URL(string: photo?.urls.regular ?? "")
    }
}
