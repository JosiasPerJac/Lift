//
//  FlightTrackerViewModel.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import Foundation
import Combine

@MainActor
final class FlightTrackerViewModel: ObservableObject {
    @Published var currentFlight: Flight?
    @Published var flightImages: FlightImages?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository: FlightRepository
    private let imageRepository: ImageRepository
    private let interpolationService: FlightInterpolationService
    private var simulationTask: Task<Void, Never>?
    
    init(
        repository: FlightRepository,
        imageRepository: ImageRepository,
        interpolationService: FlightInterpolationService? = nil
    ) {
        self.repository = repository
        self.imageRepository = imageRepository
        self.interpolationService = interpolationService ?? FlightInterpolationService()
    }
    
    // MARK: - SEARCH (API + interpolación)
    
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
    
    func stopSimulation() {
        simulationTask?.cancel()
        simulationTask = nil
    }
    
    // MARK: - SAVE FLIGHT
    
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
