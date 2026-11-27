import CoreLocation

protocol H3Caching: Actor {

    func coordinate(for h3Hex: String) -> CLLocationCoordinate2D?

    func insert(_ coordinate: CLLocationCoordinate2D, for h3Hex: String)
}

actor H3Cache: H3Caching {

    private var storage: [String: CLLocationCoordinate2D] = [:]

    func coordinate(for h3Hex: String) -> CLLocationCoordinate2D? {
        storage[h3Hex]
    }

    func insert(_ coordinate: CLLocationCoordinate2D, for h3Hex: String) {
        storage[h3Hex] = coordinate
    }
}
