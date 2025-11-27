//
//  ContentView.swift
//  Lift
//
//  Created by Josias Pérez on 20/11/25.
//

import SwiftUI
import SwiftData

/// The root view of the application serving as the main dashboard.
///
/// This view acts as the container for the app's primary navigation logic, switching between
/// the "My Flights" history list and the "Search" interface. It also manages the high-level
/// dependency injection for the `FlightTrackerViewModel` and SwiftData context.
struct ContentView: View {
    
    /// The shared view model responsible for flight logic and API state.
    @StateObject var viewModel: FlightTrackerViewModel
    
    /// The SwiftData context for performing deletion operations.
    @Environment(\.modelContext) private var modelContext
    
    /// A live query of saved flights, sorted by the most recently updated.
    @Query(sort: \FlightEntity.lastUpdated, order: .reverse) private var savedFlights: [FlightEntity]
    
    /// Controls the current active tab (History vs Search).
    @State private var selectedTab: FlightTab = .myFlights
    
    /// The current query string for the flight search input.
    @State private var iataCode = ""
    
    /// Manages the focus state of the search text field.
    @FocusState private var isFocused: Bool
    
    /// Controls the presentation of the "Passport" statistics sheet.
    @State private var showPassport = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.13, green: 0.15, blue: 0.19),
                        Color(red: 0.05, green: 0.05, blue: 0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    header
                    tabSwitcher
                    
                    Group {
                        switch selectedTab {
                        case .myFlights:
                            myFlightsView
                        case .search:
                            searchView
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPassport) {
                PassportView()
            }
        }
    }
    
    // MARK: - Header
    
    /// The top navigation bar containing the app title and the Passport button.
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lift")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Live flight tracking")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button {
                showPassport = true
            } label: {
                Image(systemName: "airplane.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.5), radius: 8)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Tabs
    
    /// A custom segmented control to switch between views.
    private var tabSwitcher: some View {
        HStack(spacing: 4) {
            ForEach(FlightTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = tab
                        isFocused = false
                    }
                } label: {
                    Text(tab.title)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                                }
                            }
                        )
                        .foregroundStyle(selectedTab == tab ? .black : .white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
    
    // MARK: - My Flights
    
    /// The view displaying the list of persisted flights.
    private var myFlightsView: some View {
        ScrollView {
            if savedFlights.isEmpty {
                emptyState
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 18) {
                    ForEach(savedFlights) { entity in
                        let domainFlight = FlightMapper.mapToDomain(entity: entity)
                        
                        NavigationLink {
                            FlightDetailView(
                                flight: domainFlight,
                                images: viewModel.flightImages,
                                onDelete: { deleteFlight(entity) },
                                viewModel: viewModel
                            )
                            .task {
                                viewModel.loadSavedFlight(entity)
                            }
                        } label: {
                            FlightListRow(
                                entity: entity,
                                onDelete: { deleteFlight(entity) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Search
    
    /// The view for searching and tracking new flights via the API.
    private var searchView: some View {
        ScrollView {
            VStack(spacing: 24) {
                searchBar
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.top, 40)
                } else if let searchResult = viewModel.currentFlight {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Result")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading, 4)
                        
                        NavigationLink(
                            destination: FlightDetailView(
                                flight: searchResult,
                                images: viewModel.flightImages,
                                onDelete: nil,
                                viewModel: viewModel
                            )
                        ) {
                            FlightCard(
                                flight: searchResult,
                                onAdd: {
                                    withAnimation(.spring()) {
                                        viewModel.saveCurrentFlight()
                                        selectedTab = .myFlights
                                        iataCode = ""
                                    }
                                },
                                isSaved: savedFlights.contains { $0.flightIata == searchResult.id }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                } else if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                        .padding(.top, 32)
                } else {
                    // Default State
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.35))
                        Text("Search a flight by number")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    .padding(.top, 60)
                }
            }
            .padding(.top, 18)
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
            
            TextField("Flight Number (e.g. AA100)", text: $iataCode)
                .foregroundStyle(.white)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.searchFlight(iata: iataCode) }
                }
            
            if iataCode.isEmpty == false {
                Button {
                    iataCode = ""
                    viewModel.currentFlight = nil
                    viewModel.errorMessage = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.4))
                }
                
                Button {
                    isFocused = false
                    Task { await viewModel.searchFlight(iata: iataCode) }
                } label: {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.5), radius: 8)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }
    
    // MARK: - Empty + delete
    
    /// A visual state shown when no flights have been saved yet.
    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.15), Color.purple.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                Image(systemName: "airplane")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .rotationEffect(.degrees(-10))
            
            Text("No flights tracked yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            
            Text("Search for a flight and start tracking it in real time.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                withAnimation(.spring()) {
                    selectedTab = .search
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Search a flight")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func deleteFlight(_ entity: FlightEntity) {
        withAnimation {
            modelContext.delete(entity)
            try? modelContext.save()
        }
    }
}

/// Defines the main navigation modes of the application.
enum FlightTab: CaseIterable {
    case myFlights
    case search
    
    var title: String {
        switch self {
        case .myFlights: return "My Flights"
        case .search: return "Search"
        }
    }
}
