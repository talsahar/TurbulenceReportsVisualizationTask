import CoreLocation

struct AirportCoordinates: Decodable, Sendable {
    let source: Airport
    let destination: Airport
}

struct Airport: Decodable, Sendable, CustomStringConvertible {
    let airport: String
    let city: String
    let latitude: Double
    let longitude: Double

    var description: String {
        "\(airport) (\(city))"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
