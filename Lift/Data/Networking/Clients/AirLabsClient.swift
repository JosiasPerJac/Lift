//
//  AviationStackClient.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// A networking client responsible for communicating with the AirLabs API.
///
/// This struct handles URL construction, query parameter encoding, and parsing
/// the specific JSON envelope format used by AirLabs.
struct AirLabsClient {
    
    /// The API key used for authentication.
    let apiKey: String

    /// Initializes the client.
    /// - Parameter apiKey: Defaults to the key found in `APIConfiguration`.
    init(apiKey: String = APIConfiguration.airLabsAPIKey) {
        self.apiKey = apiKey
    }

    /// Fetches live flight data for a specific IATA code.
    ///
    /// - Parameter iataCode: The flight identifier (e.g., "AA100"). Spaces are automatically removed.
    /// - Returns: An `AirLabsFlight` DTO if found, or `nil`.
    /// - Throws: `AirLabsError` if the network fails, the response is invalid, or the API returns a logic error.
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

        // Decodes the specific "Envelope" structure AirLabs uses (wrapping response and error fields).
        let envelope = try decoder.decode(AirLabsEnvelope<AirLabsFlight>.self, from: data)

        if let apiError = envelope.error {
            throw AirLabsError.api(message: apiError.message, code: apiError.code)
        }

        return envelope.response
    }
}

/// Errors specific to the AirLabs networking layer.
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
