//
//  FlightSearchService.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

final class FlightSearchService {
    let aviationClient: AviationStackClient
    let unsplashClient: UnsplashClient

    init(
        aviationClient: AviationStackClient = AviationStackClient(),
        unsplashClient: UnsplashClient = UnsplashClient()
    ) {
        self.aviationClient = aviationClient
        self.unsplashClient = unsplashClient
    }

    func searchFlightWithImages(flightIata: String) async throws -> FlightSearchResult? {
        let flights = try await aviationClient.fetchFlights(iataCode: flightIata, limit: 1)
        guard let flight = flights.first else {
            return nil
        }

        async let airportImage = unsplashClient.fetchSingleImage(query: airportQuery(from: flight))
        async let aircraftImage = unsplashClient.fetchSingleImage(query: aircraftQuery(from: flight))

        let (airportResult, aircraftResult) = try await (airportImage, aircraftImage)

        return FlightSearchResult(
            flight: flight,
            airportImage: airportResult,
            aircraftImage: aircraftResult
        )
    }

    private func airportQuery(from flight: AviationStackFlight) -> String {
        if let airport = flight.arrival.airport, let iata = flight.arrival.iata {
            return "\(airport) \(iata) airport"
        }
        if let airport = flight.arrival.airport {
            return "\(airport) airport"
        }
        if let airport = flight.departure.airport {
            return "\(airport) airport"
        }
        return "airport"
    }

    private func aircraftQuery(from flight: AviationStackFlight) -> String {
        if let code = flight.live?.aircraft?.iata {
            return code
        }
        if let code = flight.live?.aircraft?.icao {
            return code
        }
        return "airplane"
    }
}
