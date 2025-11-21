//
//  ContentView.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import SwiftUI

struct ContentView: View {
    // Recibimos el ViewModel ya construido e inyectado
    @StateObject var viewModel: FlightTrackerViewModel
    
    @State private var iataCode = "AA100" // Código de prueba
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Flight IATA (e.g. AA100)", text: $iataCode)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Track Flight") {
                Task {
                    await viewModel.searchFlight(iata: iataCode)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let flight = viewModel.currentFlight {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Flight: \(flight.id)")
                        .font(.title)
                    Text("Status: \(flight.status)")
                    
                    Divider()
                    
                    Text("Interpolated Position:")
                        .font(.headline)
                    Text("Lat: \(flight.latitude)")
                    Text("Lon: \(flight.longitude)")
                    
                    if let images = viewModel.flightImages {
                        Text("Images Loaded:")
                            .font(.headline)
                            .padding(.top)
                        if let airport = images.airport {
                            Text("Airport: \(airport.absoluteString)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        if let aircraft = images.aircraft {
                            Text("Aircraft: \(aircraft.absoluteString)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Text("Loading images...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            
            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
            
            Spacer()
        }
        .padding()
    }
}
