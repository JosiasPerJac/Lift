//
//  DefaultImageRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

final class DefaultImageRepository: ImageRepository {
    private let unsplashClient: UnsplashClient
    
    init(unsplashClient: UnsplashClient = UnsplashClient()) {
        self.unsplashClient = unsplashClient
    }
    
    func getImages(for flight: Flight) async throws -> FlightImages {
        async let airportPhoto = fetchAirportImage(for: flight)
        async let aircraftPhoto = fetchAircraftImage(for: flight)
        
        return try await FlightImages(airport: airportPhoto, aircraft: aircraftPhoto)
    }
    
    private func fetchAirportImage(for flight: Flight) async throws -> URL? {
        let query = "\(flight.arrivalIata) airport"
        let photo = try await unsplashClient.fetchSingleImage(query: query)
        return URL(string: photo?.urls.regular ?? "")
    }
    
    private func fetchAircraftImage(for flight: Flight) async throws -> URL? {
        let query = "\(flight.id) aircraft"
        let photo = try await unsplashClient.fetchSingleImage(query: query)
        return URL(string: photo?.urls.regular ?? "")
    }
}
