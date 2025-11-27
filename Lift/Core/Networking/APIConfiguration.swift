//
//  APIConfiguration.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

/// Centralized configuration for API endpoints and access keys.
///
/// This enum prevents hardcoding sensitive keys directly in the codebase by retrieving them
/// from the application's `Info.plist`. It ensures that the app crashes immediately (fail-fast)
/// if the required configuration is missing.
enum APIConfiguration {
    
    /// The base URL for the AirLabs v9 API.
    static let airLabsBaseURL = URL(string: "https://airlabs.co/api/v9")!
    
    /// Retrieves the AirLabs API Key from the `Info.plist`.
    ///
    /// - Warning: Calls `fatalError` if the key `AVIATION_API_KEY` is not found.
    static var airLabsAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AVIATION_API_KEY") as? String else {
            fatalError("AVIATION_API_KEY not set in Info.plist")
        }
        return key
    }

    /// The base URL for the Unsplash API.
    static let unsplashBaseURL = URL(string: "https://api.unsplash.com")!

    /// Retrieves the Unsplash Access Key from the `Info.plist`.
    ///
    /// - Warning: Calls `fatalError` if the key `UNSPLASH_ACCESS_KEY` is not found.
    static var unsplashAccessKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String else {
            fatalError("UNSPLASH_ACCESS_KEY not set in Info.plist")
        }
        return key
    }
}
