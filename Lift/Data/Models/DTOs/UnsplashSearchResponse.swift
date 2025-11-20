//
//  UnsplashSearchResponse.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct UnsplashSearchResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}

struct UnsplashPhoto: Decodable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case altDescription = "alt_description"
        case urls
        case user
    }
}

struct UnsplashPhotoURLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Decodable {
    let name: String?
    let username: String?
}
