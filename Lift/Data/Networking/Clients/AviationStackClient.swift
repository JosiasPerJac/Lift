//
//  AviationStackClient.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct AviationStackClient {
    let apiKey: String

    init(apiKey: String = APIConfiguration.aviationStackAPIKey) {
        self.apiKey = apiKey
    }

    func fetchFlights(iataCode: String, limit: Int = 1) async throws -> [AviationStackFlight] {
        var components = URLComponents(
            url: APIConfiguration.aviationStackBaseURL.appendingPathComponent("flights"),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = [
            URLQueryItem(name: "access_key", value: apiKey),
            URLQueryItem(name: "flight_iata", value: iataCode),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components?.url else {
            throw AviationStackError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw AviationStackError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(AviationStackResponse.self, from: data)
        return decoded.data
    }
}

enum AviationStackError: Error {
    case invalidURL
    case invalidResponse
}
