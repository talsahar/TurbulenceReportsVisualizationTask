import CoreLocation
import Testing

@testable import TurbulenceReportsVisualizationTask

struct H3CacheTests {

    @Test
    func coordinate_returnsNil_whenCacheIsEmpty() async {
        let cache = H3Cache()

        let result = await cache.coordinate(for: "85283473fffffff")

        #expect(result == nil)
    }

    @Test
    func insert_storesCoordinate() async {
        let cache = H3Cache()
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )
        let h3Hex = "85283473fffffff"

        await cache.insert(coordinate, for: h3Hex)

        let result = await cache.coordinate(for: h3Hex)

        #expect(result != nil)
        #expect(result?.latitude == coordinate.latitude)
        #expect(result?.longitude == coordinate.longitude)
    }

    @Test
    func coordinate_returnsCorrectCoordinate_forDifferentH3Hexes() async {
        let cache = H3Cache()

        let firstCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )

        let secondCoordinate = CLLocationCoordinate2D(
            latitude: 40.7128,
            longitude: -74.0060
        )

        await cache.insert(firstCoordinate, for: "first")
        await cache.insert(secondCoordinate, for: "second")

        let firstResult = await cache.coordinate(for: "first")
        let secondResult = await cache.coordinate(for: "second")

        #expect(firstResult?.latitude == firstCoordinate.latitude)
        #expect(firstResult?.longitude == firstCoordinate.longitude)

        #expect(secondResult?.latitude == secondCoordinate.latitude)
        #expect(secondResult?.longitude == secondCoordinate.longitude)
    }

    @Test
    func insert_overwritesExistingCoordinate() async {
        let cache = H3Cache()
        let h3Hex = "85283473fffffff"

        let originalCoordinate = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )

        let updatedCoordinate = CLLocationCoordinate2D(
            latitude: 40.7128,
            longitude: -74.0060
        )

        await cache.insert(originalCoordinate, for: h3Hex)
        await cache.insert(updatedCoordinate, for: h3Hex)

        let result = await cache.coordinate(for: h3Hex)

        #expect(result?.latitude == updatedCoordinate.latitude)
        #expect(result?.longitude == updatedCoordinate.longitude)
    }

    @Test
    func coordinate_returnsNil_forUnknownH3Hex() async {
        let cache = H3Cache()

        await cache.insert(
            CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            for: "known"
        )

        let result = await cache.coordinate(for: "unknown")

        #expect(result == nil)
    }
}
