# ``Lift``

Track flights in real-time and manage aviation data using Clean Architecture.

## Overview

**Lift** is a professional iOS application demonstrating modern development practices with **SwiftUI**, **SwiftData**, and **Swift Concurrency**. 

The project addresses real-world constraints, such as API rate limiting, by implementing a **Cache-Aside** strategy and a custom **Math Interpolation Service** to simulate live aircraft movement between network updates.

### Architecture

The app follows a strict **Clean Architecture** pattern to ensure separation of concerns and testability:

- **Domain Layer**: Contains pure business logic, models, and interface definitions.
- **Data Layer**: Manages data retrieval from the AirLabs API and persistence via SwiftData.
- **Presentation Layer**: Handles UI state and user interaction using the MVVM pattern.

## Topics

### App Entry Point
The root of the application where dependency injection is configured.
- <doc:LiftApp>
- <doc:CompositionRootView>
- <doc:APIConfiguration>

### Domain Layer (Business Logic)
The heart of the application, defining "what" the app does independent of frameworks.
- <doc:Flight>
- <doc:FlightRepository>
- <doc:ImageRepository>
- <doc:FlightInterpolationService>

### Data Layer (Persistence & Networking)
The implementation details defining "how" data is retrieved and stored.
- <doc:DefaultFlightRepository>
- <doc:DefaultImageRepository>
- <doc:FlightEntity>
- <doc:FlightMapper>
- <doc:AirLabsClient>
- <doc:UnsplashClient>

### Presentation Layer (UI & State)
Views and ViewModels that drive the user interface.
- <doc:FlightTrackerViewModel>
- <doc:ContentView>
- <doc:FlightDetailView>
- <doc:PassportView>
- <doc:FlightCard>
