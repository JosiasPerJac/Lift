//
//  LiftApp.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import SwiftUI
import SwiftData

/// The main entry point of the Lift application.
///
/// This struct is responsible for:
/// 1. Initializing the SwiftData `ModelContainer` for persistence.
/// 2. Setting up the root view hierarchy.
/// 3. Injecting the storage container into the environment.
@main
struct LiftApp: App {
    
    /// The SwiftData container that manages the schema and storage for `FlightEntity`.
    let container: ModelContainer
    
    /// Initializes the application and sets up the database container.
    ///
    /// - Note: If the container fails to initialize (e.g., schema mismatch), the app will crash with a fatal error.
    init() {
        do {
            container = try ModelContainer(for: FlightEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // We use a Composition Root to handle Dependency Injection
            CompositionRootView()
        }
        .modelContainer(container)
    }
}

/// A specialized root view responsible for the **Dependency Injection** graph.
///
/// This view acts as the "Composition Root" of the application. Its sole purpose is to:
/// - Retrieve the `modelContext` from the environment (provided by `LiftApp`).
/// - Instantiate the low-level Networking clients.
/// - Instantiate the Data Repositories using the clients and the database context.
/// - Assemble the `FlightTrackerViewModel`.
/// - Inject the configured ViewModel into the `ContentView`.
struct CompositionRootView: View {
    
    /// The database context required by the repositories.
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // 1. Create Low-Level Clients
        let airLabsClient = AirLabsClient()
        let unsplashClient = UnsplashClient()

        // 2. Create Repositories (Data Layer)
        let flightRepo = DefaultFlightRepository(
            airLabsClient: airLabsClient,
            modelContext: modelContext
        )

        let imageRepo = DefaultImageRepository(
            unsplashClient: unsplashClient
        )

        // 3. Inject into Presentation Layer
        ContentView(
            viewModel: FlightTrackerViewModel(
                repository: flightRepo,
                imageRepository: imageRepo
            )
        )
    }
}
