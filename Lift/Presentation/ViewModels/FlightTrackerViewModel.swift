//
//  FlightTrackerViewModel.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import Combine

/// The primary view model managing the flight tracking interface and logic.
///
/// This class is responsible for orchestrating data flow between the data layer
/// (Repositories) and the UI. It handles:
/// - Fetching live flight data.
/// - Loading saved flights from local persistence (SwiftData).
/// - Managing asynchronous image loading.
/// - **Interpolating flight positions** to simulate real-time movement between API updates.
@MainActor
final class FlightTrackerViewModel: ObservableObject {
    
    /// The current flight being tracked and displayed.
    @Published var currentFlight: Flight?
    
    /// The visual assets (airport and aircraft images) associated with the current flight.
    @Published var flightImages: FlightImages?
    
    /// A flag indicating whether a network operation is currently in progress.
    @Published var isLoading: Bool = false
    
    /// Contains a user-friendly error message if an operation fails.
    @Published var errorMessage: String?
    
    private let repository: FlightRepository
    private let imageRepository: ImageRepository
    
    /// The service responsible for calculating intermediate positions.
    ///
    /// This service allows the app to show smooth aircraft movement on the map
    /// without needing to poll the API every second.
    private let interpolationService: FlightInterpolationService
    
    /// A reference to the background task running the position simulation loop.
    private var simulationTask: Task<Void, Never>?
    
    /// Initializes the view model with required dependencies.
    ///
    /// - Parameters:
    ///   - repository: The source for flight data.
    ///   - imageRepository: The source for flight-related images.
    ///   - interpolationService: The service for position simulation. Defaults to a new instance.
    init(
        repository: FlightRepository,
        imageRepository: ImageRepository,
        interpolationService: FlightInterpolationService? = nil
    ) {
        self.repository = repository
        self.imageRepository = imageRepository
        self.interpolationService = interpolationService ?? FlightInterpolationService()
    }
    
    // MARK: - SEARCH (API + Interpolation)
    
    /// Searches for a flight by its IATA code and initiates tracking.
    ///
    /// This method performs the following steps:
    /// 1. Fetches flight data from the repository (API or Cache).
    /// 2. Starts the position interpolation loop.
    /// 3. Asynchronously fetches related images (aircraft/airport) without blocking the UI.
    ///
    /// - Parameter iata: The IATA flight code (e.g., "AA123").
    func searchFlight(iata: String) async {
        isLoading = true
        errorMessage = nil
        stopSimulation()
        
        do {
            let flight = try await repository.getFlight(iata: iata)
            self.currentFlight = flight
            
            if let flight = flight {
                startSimulation()
                
                Task {
                    do {
                        let images = try await imageRepository.getImages(for: flight)
                        self.flightImages = images
                    } catch {
                        print("Error loading images: \(error)")
                    }
                }
            } else {
                errorMessage = "Flight not found"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - LOAD FROM SWIFTDATA (My Flights, WITHOUT API)
    
    /// Loads a flight directly from a local database entity.
    ///
    /// Use this method when selecting a flight from the "My Flights" history list.
    /// It skips the API fetch but still triggers image loading and position simulation.
    ///
    /// - Parameter entity: The SwiftData `FlightEntity` selected by the user.
    func loadSavedFlight(_ entity: FlightEntity) {
        stopSimulation()
        errorMessage = nil
        
        let flight = FlightMapper.mapToDomain(entity: entity)
        self.currentFlight = flight
        
        startSimulation()
        
        Task {
            do {
                let images = try await imageRepository.getImages(for: flight)
                self.flightImages = images
            } catch {
                print("Error loading images for saved flight: \(error)")
            }
        }
    }
    
    // MARK: - SIMULATION / INTERPOLATION
    
    /// Starts the background simulation loop to update the aircraft's position.
    ///
    /// This method creates a recurring task that updates `currentFlight` every second
    /// using the `interpolationService`. This creates a smooth animation effect on the map
    /// independent of the actual API refresh rate.
    private func startSimulation() {
        stopSimulation()
        
        simulationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
                
                if Task.isCancelled { return }
                guard let self = self else { return }
                
                if let flight = self.currentFlight {
                    let updatedFlight = self.interpolationService.interpolatePosition(for: flight)
                    self.currentFlight = updatedFlight
                }
            }
        }
    }
    
    /// Stops the currently running position simulation task.
    ///
    /// Call this when the view disappears or when a new search is initiated to prevent memory leaks.
    func stopSimulation() {
        simulationTask?.cancel()
        simulationTask = nil
    }
    
    // MARK: - SAVE FLIGHT
    
    /// Persists the currently tracked flight to the local database ("My Flights").
    ///
    /// - Note: After saving, the current flight state is cleared from the view.
    func saveCurrentFlight() {
        guard let flight = currentFlight else { return }
        
        do {
            try repository.saveFlight(flight)
            Task { @MainActor in
                self.currentFlight = nil
            }
        } catch {
            self.errorMessage = "Failed to save flight: \(error.localizedDescription)"
        }
    }
}
