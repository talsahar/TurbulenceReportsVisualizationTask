
import XCTest
import CoreLocation
@testable import TurbulenceReportsVisualizationTask

final class TurbulenceObservationFilteringServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testKeepLatestObservationPerCoordinate_RemovesOlderDuplicates() {
        // Given
        let coordinate = CLLocationCoordinate2D(
            latitude: 32.0,
            longitude: 34.0
        )

        let observations = [
            makeObservation(coordinate: coordinate, ts: 100),
            makeObservation(coordinate: coordinate, ts: 300),
            makeObservation(coordinate: coordinate, ts: 200)
        ]

        // When
        let result = TurbulenceObservationFilteringService.keepLatestObservationPerCoordinate(
            from: observations
        )

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.timestamp, 300)
    }

    func testKeepLatestObservationPerCoordinate_KeepsDifferentCoordinates() {
        // Given
        let observations = [
            makeObservation(
                coordinate: CLLocationCoordinate2D(latitude: 32.0, longitude: 34.0),
                ts: 100
            ),
            makeObservation(
                coordinate: CLLocationCoordinate2D(latitude: 31.0, longitude: 35.0),
                ts: 200
            )
        ]

        // When
        let result = TurbulenceObservationFilteringService.keepLatestObservationPerCoordinate(
            from: observations
        )

        // Then
        XCTAssertEqual(result.count, 2)
    }

    func testKeepLatestObservationPerCoordinate_HandlesEmptyArray() {
        // When
        let result = TurbulenceObservationFilteringService.keepLatestObservationPerCoordinate(from: [])

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func testKeepLatestObservationPerCoordinate_KeepsSingleObservation() {
        // Given
        let observations = [
            makeObservation(
                coordinate: CLLocationCoordinate2D(latitude: 32.0, longitude: 34.0),
                ts: 100
            )
        ]

        // When
        let result = TurbulenceObservationFilteringService.keepLatestObservationPerCoordinate(
            from: observations
        )

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.timestamp, 100)
    }

    // MARK: - Helpers

    private func makeObservation(
        coordinate: CLLocationCoordinate2D,
        ts: Int,
        sev: Int = 2,
        altFt: Int = 30000
    ) -> TurbulenceObservation {
        TurbulenceObservation(
            coordinate: coordinate,
            timestamp: ts,
            severity: sev,
            altitudeFeet: altFt
        )
    }
}
