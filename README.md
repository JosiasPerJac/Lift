# ✈️ Lift

Lift is a flight tracking application that integrates the AirLabs API to visualize real-time aircraft telemetry, routes, and status.

Unlike standard trackers that rely solely on static API responses, Lift implements a custom Mathematical Interpolation Engine. This allows the app to simulate live, smooth aircraft movement on the map between network updates, overcoming API rate limits and providing a fluid user experience.

The app is fully offline-capable using SwiftData, allowing users to save flights to a personal "Passport" and view their travel statistics.

# Technologies Used
* SwiftUI
* SwiftData
* Swift Concurrency (async/await)
* URLSession (REST APIs)
* AirLabs API & Unsplash API
* DocC
* Git & GitHub

# 📱 App Demo

https://github.com/user-attachments/assets/d1fb6f72-55de-48b3-8dc1-491df2e81dc6

# 📸 Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/6b41aab2-3785-4c80-b986-72d207c7c14e" width="270" alt="Lift Home Screen"/>
  <img src="https://github.com/user-attachments/assets/b6be0260-651c-48af-adad-ff80b30430fd" width="270" alt="Lift Flight Search"/>
  <img src="https://github.com/user-attachments/assets/d7920c3c-b806-49bd-b993-5356550d622c" width="270" alt="Lift Flight Detail"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/7e9b920c-e835-4be6-a41d-f58436691cdf" width="270" alt="Lift Map View"/>
  <img src="https://github.com/user-attachments/assets/91a90db2-b7be-47ef-9fe1-b775110119c9" width="270" alt="Lift History"/>
  <img src="https://github.com/user-attachments/assets/8067238a-db2b-4ce9-8a9c-a22a39d3ac1a" width="270" alt="Lift Settings"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/af32a6ca-a680-461b-b96f-277b37383b52" width="270" alt="Lift Dark Mode"/>
</p>

# I'm Most Proud Of...
The "Smart Interpolation" logic for flight progress. Because the AirLabs free tier limits users to only 1000 requests per month, I couldn't poll the server constantly to update the progress bar.

I solved this by fetching the exact data once and then running a local calculation to estimate the plane's current position based on the departure time, arrival time, and current timestamp. This allows the UI to update smoothly every second without hitting the API, reducing network usage by over 90%.

Here's the code:

```swift
    // Calculates the normalized progress (0.0 to 1.0) of a flight
    // to update the UI without triggering a new API call.
    func calculateLiveProgress(departure: Date, arrival: Date) -> Double {
        let totalDuration = arrival.timeIntervalSince(departure)
        let timeElapsed = Date.now.timeIntervalSince(departure)
        
        // Prevent division by zero or invalid dates
        guard totalDuration > 0 else { return 0.0 }
        
        let progress = timeElapsed / totalDuration
        
        // Clamp the value to ensure the progress bar never exceeds 0% or 100%
        // regardless of slight time zone discrepancies.
        return min(max(progress, 0.0), 1.0)
    }
```
<br>
</br>

# Completeness
Although it's a simple portfolio project, I've implemented the following
* Robust Error Handling (API failures/Limits)
* Empty States & Loading States
* Adaptive Layouts (iPhone SE to 17 Pro Max)
* Code documentation (DocC)
* Project organization (Clean MVVM structure and reusable components)
