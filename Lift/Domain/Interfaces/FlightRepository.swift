//
//  FlightRepository.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation

protocol FlightRepository {
    func getFlight(iata: String) async throws -> Flight?
}
