//
//  ImageRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

struct FlightImages: Sendable {
    let airport: URL?
    let aircraft: URL?
}

protocol ImageRepository: Sendable {
    func getImages(for flight: Flight) async throws -> FlightImages
}
