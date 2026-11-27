
import CoreLocation

protocol DistanceCalculating {
    func distanceInMiles(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> Double
}

struct DistanceCalculator: DistanceCalculating {

    private static let metersPerMile = 1609.344

    func distanceInMiles(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> Double {
        let startLocation = CLLocation(
            latitude: start.latitude,
            longitude: start.longitude
        )

        let endLocation = CLLocation(
            latitude: end.latitude,
            longitude: end.longitude
        )

        return startLocation.distance(from: endLocation) / Self.metersPerMile
    }
}
