
import CoreLocation

protocol PrepareTurbulenceReportUseCase {
    
    @concurrent
    func execute() async throws -> TurbulenceReport
}

final class PrepareTurbulenceReportUseCaseImpl:
    PrepareTurbulenceReportUseCase {
    
    private let turbulenceRepository: TurbulenceRepository
    private let airportCoordinatesProvider: AirportCoordinatesProvider
    
    init(
        turbulenceRepository: TurbulenceRepository,
        airportCoordinatesProvider: AirportCoordinatesProvider
    ) {
        self.turbulenceRepository = turbulenceRepository
        self.airportCoordinatesProvider = airportCoordinatesProvider
    }
    
    @concurrent
    func execute() async throws -> TurbulenceReport {
        
        async let observations =
        turbulenceRepository.fetchObservations()
        
        async let coordinates =
        airportCoordinatesProvider.fetchCoordinates()
        
        let (reportObservations, airportCoordinates) = try await (
            observations,
            coordinates
        )
        
        let sourceCoordinate = await airportCoordinates.source.coordinate
        let destinationCoordinate = await airportCoordinates.destination.coordinate
        
        guard await isValid(sourceCoordinate),
              await isValid(destinationCoordinate) else {
            throw PrepareTurbulenceReportError
                .invalidAirportCoordinates
        }
        
        let airportDistanceMiles = await DistanceCalculator.distanceInMiles(
            from: sourceCoordinate,
            to: destinationCoordinate
        )
        
        guard airportDistanceMiles.isFinite,
              airportDistanceMiles > 0 else {
            throw PrepareTurbulenceReportError
                .invalidAirportDistance
        }
        
        let mappedObservations = await TurbulenceReportMapper.map(
            observations: reportObservations,
            sourceCoordinate: sourceCoordinate,
            airportDistanceMiles: airportDistanceMiles
        )
        
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
}

enum PrepareTurbulenceReportError: Error {
    case invalidAirportCoordinates
    case invalidAirportDistance
}
