import CoreLocation

protocol H3Coordinating {
    func coordinate(for h3Hex: String) async -> CLLocationCoordinate2D
}

final class H3Coordinator: H3Coordinating {

    private let cache: H3Caching

    init(cache: H3Caching = H3Cache()) {
        self.cache = cache
    }

    func coordinate(for h3Hex: String) async -> CLLocationCoordinate2D {
        guard let cached = await cache.coordinate(for: h3Hex) else {
            let coordinate = H3.hexToCoord(h3Hex)
            await cache.insert(coordinate, for: h3Hex)
            return coordinate
        }

        return cached
    }
}
