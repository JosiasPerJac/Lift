//
//  ImageRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// A data structure representing the visual assets associated with a flight.
///
/// This structure holds the URLs for images retrieved from external sources.
struct FlightImages: Sendable {
    
    /// The URL for the airport's image.
    let airport: URL?
    
    /// The URL for the aircraft's image.
    let aircraft: URL?
}

/// Defines the contract for retrieving visual assets associated with a flight.
///
/// Implementations of this protocol are responsible for fetching relevant images
/// (e.g., from Unsplash) to enhance the UI.
protocol ImageRepository: Sendable {
    
    /// Retrieves a set of images relevant to the provided flight.
    ///
    /// - Parameter flight: The `Flight` domain entity for which images are requested.
    /// - Returns: A `FlightImages` object containing optional URLs for the airport and aircraft.
    /// - Throws: An error if the network request or mapping fails.
    func getImages(for flight: Flight) async throws -> FlightImages
}
