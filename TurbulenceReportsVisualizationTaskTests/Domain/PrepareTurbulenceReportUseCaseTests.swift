
import Testing
@testable import TurbulenceReportsVisualizationTask
internal import _LocationEssentials

struct PrepareTurbulenceReportUseCaseTests {

    @Test("Prepares turbulence report using real data")
    func executeWithRealData() async throws {
        // Arrange
        let H3Cache = H3Cache()
        let h3Coordinator = await H3Coordinator(cache: H3Cache)
        let dataProvider = try await LocalJSONTurbulenceDataProvider()
        let repository = await TurbulenceRepositoryImpl(
            h3Coordinator: h3Coordinator,
            dataProvider: dataProvider
        )

        let sut = await PrepareTurbulenceReportUseCaseImpl(
            turbulenceRepository: repository,
            airportCoordinatesProvider: AirportCoordinatesJSONProvider()
        )

        // Act & Measure
        let clock = ContinuousClock()
        let start = clock.now

        let report = try await sut.execute()

        let duration = start.duration(to: clock.now)

        // Assert
        #expect(report.airportDistanceMiles > 0)

        await #expect(!report.airportCoordinates.source.coordinate.latitude.isNaN)
        await #expect(!report.airportCoordinates.destination.coordinate.latitude.isNaN)

        for observation in await report.observations {
            #expect(observation.normalizedDistance >= 0)
            #expect(observation.normalizedDistance <= 1)
            #expect(observation.flightLevel >= 0)
            #expect(
                observation.flightLevel <= Constants.turbulenceReportMaxFL
            )
        }

        print("Execution duration: \(duration)")
        print("Observations count: \(await report.observations.count)")
        print("Airports distance: \(await report.airportDistanceMiles) miles")
    }
}
