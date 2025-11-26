//
//  LiftApp.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import SwiftUI
import SwiftData

@main
struct LiftApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: FlightEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CompositionRootView()
        }
        .modelContainer(container)
    }
}

struct CompositionRootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let airLabsClient = AirLabsClient()
        let unsplashClient = UnsplashClient()

        let flightRepo = DefaultFlightRepository(
            airLabsClient: airLabsClient,
            modelContext: modelContext
        )

        let imageRepo = DefaultImageRepository(
            unsplashClient: unsplashClient
        )

        ContentView(
            viewModel: FlightTrackerViewModel(
                repository: flightRepo,
                imageRepository: imageRepo
            )
        )
    }
}

