
import CoreLocation

protocol PrepareTurbulenceReportUseCase {
    @concurrent
    func execute() async throws -> TurbulenceReport
}

final class PrepareTurbulenceReportUseCaseImpl: PrepareTurbulenceReportUseCase {
    
    private let turbulenceRepository: TurbulenceRepository
    private let airportCoordinatesProvider: AirportCoordinatesProvider
    private let filteringService: TurbulenceObservationFiltering
    private let distanceCalculator: DistanceCalculating
    
    init(
        turbulenceRepository: TurbulenceRepository,
        airportCoordinatesProvider: AirportCoordinatesProvider,
        filteringService: TurbulenceObservationFiltering,
        distanceCalculator: DistanceCalculating
    ) {
        self.turbulenceRepository = turbulenceRepository
        self.airportCoordinatesProvider = airportCoordinatesProvider
        self.filteringService = filteringService
        self.distanceCalculator = distanceCalculator
    }
    
    func execute() async throws -> TurbulenceReport {
        async let observations = turbulenceRepository.fetchObservations()
        async let coordinates = airportCoordinatesProvider.fetchCoordinates()
        
        let (reportObservations, airportCoordinates) = try await (
            observations,
            coordinates
        )
        
        let sourceCoordinate = airportCoordinates.source.coordinate
        let destinationCoordinate = airportCoordinates.destination.coordinate
        
        guard isValid(sourceCoordinate), isValid(destinationCoordinate) else {
            throw PrepareTurbulenceReportError.invalidAirportCoordinates
        }
        
        let airportDistanceMiles = distanceCalculator.distanceInMiles(
            from: sourceCoordinate,
            to: destinationCoordinate
        )
        
        guard airportDistanceMiles.isFinite, airportDistanceMiles > 0 else {
            throw PrepareTurbulenceReportError.invalidAirportDistance
        }
        
        let validObservations = reportObservations.filter {
            TurbulenceReportObservation.Severity(
                rawValue: $0.severity
            ) != nil
        }
        
        let filteredObservations = filteringService
            .keepLatestObservationPerCoordinate(from: validObservations)
        
        let mappedObservations = filteredObservations.compactMap {
            mapObservation(
                $0,
                sourceCoordinate: sourceCoordinate,
                airportDistanceMiles: airportDistanceMiles
            )
        }
        
        return TurbulenceReport(
            observations: mappedObservations,
            airportCoordinates: airportCoordinates,
            airportDistanceMiles: airportDistanceMiles
        )
    }
    
    private func isValid(
        _ coordinate: CLLocationCoordinate2D
    ) -> Bool {
        CLLocationCoordinate2DIsValid(coordinate) &&
        coordinate.latitude.isFinite &&
        coordinate.longitude.isFinite
    }
    
    private func mapObservation(
        _ observation: TurbulenceObservation,
        sourceCoordinate: CLLocationCoordinate2D,
        airportDistanceMiles: Double
    ) -> TurbulenceReportObservation? {
        guard let severity = TurbulenceReportObservation.Severity(
            rawValue: observation.severity
        ) else {
            return nil
        }
        
        let normalizedDistance = normalizedDistance(
            from: sourceCoordinate,
            to: observation.coordinate,
            totalDistance: airportDistanceMiles
        )
        
        return TurbulenceReportObservation(
            flightLevel: observation.altitudeFeet / 100,
            severity: severity,
            normalizedDistance: normalizedDistance
        )
    }
    
    private func normalizedDistance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        totalDistance: Double
    ) -> Float {
        let distance = distanceCalculator.distanceInMiles(
            from: origin,
            to: destination
        )
        
        guard distance.isFinite else {
            return 0
        }
        
        return Float(min(max(distance / totalDistance, 0), 1))
    }
}

enum PrepareTurbulenceReportError: Error {
    case invalidAirportCoordinates
    case invalidAirportDistance
}
