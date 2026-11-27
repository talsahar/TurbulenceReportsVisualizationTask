
import CoreLocation

protocol TurbulenceObservationFiltering: Sendable {
    func keepLatestObservationPerCoordinate(
        from observations: [TurbulenceObservation]
    ) -> [TurbulenceObservation]

}

struct TurbulenceObservationFilteringService: TurbulenceObservationFiltering {

    func keepLatestObservationPerCoordinate(
        from observations: [TurbulenceObservation]
    ) -> [TurbulenceObservation] {

        var latestByCoordinate: [CoordinateKey: TurbulenceObservation] = [:]

        for observation in observations {
            let key = CoordinateKey(coordinate: observation.coordinate)

            if let existing = latestByCoordinate[key],
               existing.timestamp >= observation.timestamp {
                continue
            }

            latestByCoordinate[key] = observation
        }

        return Array(latestByCoordinate.values)
    }
}

private struct CoordinateKey: Hashable {
    let latitude: Double
    let longitude: Double

    init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
}
