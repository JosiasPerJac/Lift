//
//  AviationStackClient.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

import Foundation

struct AirLabsClient {
    let apiKey: String

    init(apiKey: String = APIConfiguration.airLabsAPIKey) {
        self.apiKey = apiKey
    }

    func fetchFlight(iataCode: String) async throws -> AirLabsFlight? {
        let cleaned = iataCode.uppercased().replacingOccurrences(of: " ", with: "")

        var components = URLComponents(
            url: APIConfiguration.airLabsBaseURL.appendingPathComponent("flight"),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "flight_iata", value: cleaned)
        ]

        guard let url = components?.url else {
            throw AirLabsError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AirLabsError.invalidResponse
        }

        let decoder = JSONDecoder()

        let envelope = try decoder.decode(AirLabsEnvelope<AirLabsFlight>.self, from: data)

        if let apiError = envelope.error {
            throw AirLabsError.api(message: apiError.message, code: apiError.code)
        }

        return envelope.response
    }
}

enum AirLabsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case api(message: String, code: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Endpoint no connection"
        case let .api(message, code): return "\(message) (\(code))"
        }
    }
}
