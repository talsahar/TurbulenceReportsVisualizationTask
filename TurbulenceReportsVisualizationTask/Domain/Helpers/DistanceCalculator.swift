
import CoreLocation

struct DistanceCalculator {

    private static let metersPerMile = 1609.344

    static func distanceInMiles(
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
