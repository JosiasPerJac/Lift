//
//  APIConfiguration.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

enum APIConfiguration {
    static let aviationStackBaseURL = URL(string: "https://api.aviationstack.com/v1")!

    static var aviationStackAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AVIATION_API_KEY") as? String else {
            fatalError("AVIATION_API_KEY not set in Info.plist")
        }
        return key
    }

    static let unsplashBaseURL = URL(string: "https://api.unsplash.com")!

    static var unsplashAccessKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_ACCESS_KEY") as? String else {
            fatalError("UNSPLASH_ACCESS_KEY not set in Info.plist")
        }
        return key
    }
}
