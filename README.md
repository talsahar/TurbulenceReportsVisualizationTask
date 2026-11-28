# Turbulence Reports Visualization

An iOS application that visualizes flight turbulence observations along
a route between two airports. The project uses Swift, SwiftUI, MetalKit,
and Clean Architecture to separate business logic, data management, and
visualization.

<img width="2622" height="1206" alt="Simulator Screenshot - iPhone 17 Pro - 2026-11-27 at 23 30 47" src="https://github.com/user-attachments/assets/f5d6c9b9-d3c2-4a3c-a7c1-c6ee035fb903" />

## Overview

The application processes turbulence observations and airport
coordinates to prepare a report containing:

-   Turbulence severity levels.
-   Flight levels (altitude in hundreds of feet).
-   Distance information relative to the departure airport.
-   Departure and destination airport information.
-   A graphical visualization of turbulence observations.

* Important: For better visualization, app locked support only on portrait mode.

The chart is rendered using **MetalKit** for GPU-accelerated drawing.

## Architecture

The project follows Clean Architecture, separating responsibilities into
three main layers:

``` text
TurbulenceReportsVisualizationTask
├── Presentation
│   ├── Views
│   ├── ViewModels
│   └── MetalTurbulenceReportView
│
├── Domain
│   ├── Entities
│   ├── UseCases
│   ├── Repositories
│   └── Services
│
└── Data
    ├── DataSources
    ├── Repositories
    └── DTOs
```

### Presentation Layer

Responsible for displaying the turbulence report and managing UI state.

-   **TurbulenceReportView** --- SwiftUI screen displaying the report.
-   **TurbulenceReportViewModel** --- Coordinates data retrieval and
    exposes presentation state.
-   **MetalTurbulenceReportView** --- Integrates the Metal renderer with
    SwiftUI through `UIViewRepresentable`.

### Domain Layer

Contains the application's business logic and core models.

-   **Entities** --- Domain representations of turbulence observations,
    airport coordinates, and reports.
-   **Use Cases** --- Orchestrate operations required by the
    application.
-   **Repository Protocols** --- Define data access contracts.
-   **Domain Services** --- Handle reusable business operations such as
    distance calculation and observation filtering.

### Data Layer

Responsible for retrieving and transforming external data.

-   **DTOs** --- Represent the incoming data format.
-   **Data Sources** --- Retrieve and decode source data.
-   **Repositories** --- Implement domain repository protocols and
    provide domain models.

## Data Flow

The report preparation process follows this sequence:

1.  The SwiftUI view triggers data loading.
2.  The ViewModel invokes `PrepareTurbulenceReportUseCase`.
3.  The use case retrieves turbulence observations and airport
    coordinates.
4.  Observations are filtered and deduplicated, keeping the latest
    observation for each coordinate.
5.  Airport distance is calculated.
6.  Observations are converted into report models, including severity,
    flight level, and normalized distance.
7.  The resulting report is returned to the ViewModel.
8.  The ViewModel updates its observable state.
9.  SwiftUI updates the screen and passes observations to the Metal
    renderer.

## MetalKit Visualization

The chart uses MetalKit for GPU-accelerated rendering.

### Rendering Components

-   **MetalTurbulenceRenderer** --- Implements `MTKViewDelegate` and
    manages the rendering lifecycle.
-   **VertexFactory** --- Generates vertex geometry for the grid, axes,
    and turbulence observations.
-   **Vertex** --- Represents a vertex with a 2D position and RGBA
    color.
-   **MTLBuffer** --- Stores generated vertex data for GPU access.
-   **MTLRenderPipelineState** --- Holds the configured vertex and
    fragment shaders.

### Rendering Process

The renderer separates geometry preparation from drawing:

1.  Grid and axis vertices are generated when the renderer initializes
    or the drawable size changes.
2.  Turbulence observation vertices are generated when new observations
    arrive or the drawable size changes.
3.  `draw(in:)` submits rendering commands to Metal.
4.  Grid lines, axes, and observations are rendered using line and
    triangle primitives.
5.  The resulting drawable is presented on screen.

This approach avoids regenerating static grid geometry every frame.

## Technologies

  Technology               Purpose
  ------------------------ --------------------------------------------------
  Swift                    Application development
  SwiftUI                  User interface
  UIKit                    Metal view integration
  MetalKit                 GPU-accelerated chart rendering
  Metal Shading Language   Vertex and fragment shaders
  CoreLocation             Geographic coordinates and distance calculations
  Swift Concurrency        Asynchronous data processing
  Swift Testing            Unit testing

## Testing

The project uses Swift Testing to validate application logic.

Tests should cover:

-   Repository data retrieval and mapping.
-   Use case report preparation.
-   Observation filtering and deduplication.
-   Distance calculations.
-   Invalid or missing airport coordinates.
-   Empty observation datasets.
-   Severity and flight-level mapping.

## Design Principles

The implementation aims to follow these principles:

-   **Separation of concerns** --- Each layer has a clearly defined
    responsibility.
-   **Dependency inversion** --- Domain logic depends on abstractions
    rather than concrete data implementations.
-   **Testability** --- Business logic is isolated from UI and
    infrastructure.
-   **Single responsibility** --- Components focus on one primary
    responsibility.
-   **Rendering efficiency** --- Static and dynamic geometry are updated
    independently.

## Future Improvements

Potential areas for further development:

-   Offline support, caching fetched data before flight
-   Improved rendering performance for large datasets.
-   Data streaming - TurbulenceDataProvider can provide async stream with HTTPSocket, allowing TurbulenceRepository expose an AsyncStream object. This way our report can receive live updates and refresh in any update
# TurbulenceReportsVisualizationTask
