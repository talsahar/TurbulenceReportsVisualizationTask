import CoreLocation
import Testing

@testable import TurbulenceReportsVisualizationTask

struct H3CoordinatorTests {

    @Test
    func coordinate_returnsCachedCoordinate_whenCacheHit() async {
        let h3Hex = "85283473fffffff"
        let cachedCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )

        let cache = MockH3Cache()
        await cache.insert(cachedCoordinate, for: h3Hex)

        let sut = await H3Coordinator(cache: cache)

        let result = await sut.coordinate(for: h3Hex)

        #expect(result.latitude == cachedCoordinate.latitude)
        #expect(result.longitude == cachedCoordinate.longitude)

    }

    @Test
    func coordinate_calculatesCoordinate_whenCacheMiss() async {
        let h3Hex = "85283473fffffff"

        let cache = MockH3Cache()
        let sut = await H3Coordinator(cache: cache)

        let result = await sut.coordinate(for: h3Hex)
        let expectedCoordinate = await H3.hexToCoord(h3Hex)

        #expect(result.latitude == expectedCoordinate.latitude)
        #expect(result.longitude == expectedCoordinate.longitude)
    }

    @Test
    func coordinate_insertsCalculatedCoordinate_intoCache() async {
        let h3Hex = "85283473fffffff"

        let cache = MockH3Cache()
        let sut = await H3Coordinator(cache: cache)

        let result = await sut.coordinate(for: h3Hex)
        let cachedCoordinate = await cache.coordinate(for: h3Hex)

        #expect(cachedCoordinate != nil)
        #expect(cachedCoordinate?.latitude == result.latitude)
        #expect(cachedCoordinate?.longitude == result.longitude)
    }

    @Test
    func coordinate_usesCache_onSubsequentCalls() async {
        let h3Hex = "85283473fffffff"

        let cache = MockH3Cache()
        let sut = await H3Coordinator(cache: cache)

        let firstResult = await sut.coordinate(for: h3Hex)
        let secondResult = await sut.coordinate(for: h3Hex)

        #expect(firstResult.latitude == secondResult.latitude)
        #expect(firstResult.longitude == secondResult.longitude)
    }
}

// MARK: - Mock

private final actor MockH3Cache: H3Caching {

    private var storage: [String: CLLocationCoordinate2D] = [:]

    private(set) var insertCallCount = 0

    func coordinate(for h3Hex: String) -> CLLocationCoordinate2D? {
        storage[h3Hex]
    }

    func insert(
        _ coordinate: CLLocationCoordinate2D,
        for h3Hex: String
    ) {
        insertCallCount += 1
        storage[h3Hex] = coordinate
    }
}
