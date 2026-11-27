import Testing
import Foundation
@testable import TurbulenceReportsVisualizationTask

struct AirportCoordinatesDataProviderTests {

    @Test
    func fetchCoordinatesReturnsCorrectAirportCoordinates() async throws {
        // Given
        let sut = try await AirportCoordinatesJSONProvider()

        // When
        let result = try await sut.fetchCoordinates()

        // Then
        await #expect(result.source.airport == "KLAX")
        await #expect(result.source.city == "Los Angeles")
        await #expect(result.source.latitude == 33.942802)
        await #expect(result.source.longitude == -118.403441)
        await #expect(result.destination.airport == "KPHL")
        await #expect(result.destination.city == "Philadelphia")
        await #expect(result.destination.latitude == 39.872926)
        await #expect(result.destination.longitude == -75.243943)
    }
}

