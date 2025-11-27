//
//  FlightListRow.swift
//  Lift
//
//  Created by Josias Pérez on 21/11/25.
//

import SwiftUI

/// A list row wrapper for displaying a saved flight entity.
///
/// This view handles the conversion from the `FlightEntity` (SwiftData) to the `Flight` (Domain)
/// model required by the `FlightCard`.
struct FlightListRow: View {
    let entity: FlightEntity
    let onDelete: () -> Void

    var body: some View {
        let flightModel = FlightMapper.mapToDomain(entity: entity)
        FlightCard(flight: flightModel)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
