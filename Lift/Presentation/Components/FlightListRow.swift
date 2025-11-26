//
//  FlightListRow.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI

struct FlightListRow: View {
    let entity: FlightEntity
    let onDelete: () -> Void

    var body: some View {
        let flightModel = FlightMapper.mapToDomain(entity: entity)
        FlightCard(flight: flightModel)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
