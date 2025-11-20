//
//  UnsplashClient.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct UnsplashClient {
    let accessKey: String

    init(accessKey: String = APIConfiguration.unsplashAccessKey) {
        self.accessKey = accessKey
    }

    func searchPhotos(query: String, page: Int = 1, perPage: Int = 1) async throws -> [UnsplashPhoto] {
        var components = URLComponents(
            url: APIConfiguration.unsplashBaseURL.appendingPathComponent("search/photos"),
            resolvingAgainstBaseURL: false
        )

        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        guard let url = components?.url else {
            throw UnsplashError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw UnsplashError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(UnsplashSearchResponse.self, from: data)
        return decoded.results
    }

    func fetchSingleImage(query: String) async throws -> UnsplashPhoto? {
        let results = try await searchPhotos(query: query, page: 1, perPage: 1)
        return results.first
    }
}

enum UnsplashError: Error {
    case invalidURL
    case invalidResponse
}
