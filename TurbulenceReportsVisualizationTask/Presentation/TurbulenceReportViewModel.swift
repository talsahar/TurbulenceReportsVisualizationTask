import Foundation
import Observation

@MainActor
@Observable
final class TurbulenceReportViewModel {

    private let prepareTurbulenceReportUseCase: PrepareTurbulenceReportUseCase

    private(set) var title = "Turbulence Reports"
    private(set) var observations: [TurbulenceReportObservation] = []
    private(set) var errorMessage: String?
    private(set) var sourceAirportText: String?
    private(set) var destinationAirportText: String?
    private(set) var airportDistanceMiles: Double = 0
    private(set) var isLoading = false

    var flightLevelAxisLabels: [String] {
        stride(
            from: Constants.turbulenceReportMaxFL,
            through: 0,
            by: -100
        ).map {
            "FL\(String(format: "%03d", $0))"
        }
    }

    var distanceAxisLabels: [Int] {
        (0..<Constants.turbulenceReportDistanceLabelsCount).map { index in
            let progress = Double(index) / Double(Constants.turbulenceReportDistanceLabelsCount - 1)
            return Int((airportDistanceMiles * progress).rounded())
        }
    }

    init(prepareTurbulenceReportUseCase: PrepareTurbulenceReportUseCase) {
        self.prepareTurbulenceReportUseCase = prepareTurbulenceReportUseCase
    }

    func fetchData() async {
        guard !isLoading else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let report = try await prepareTurbulenceReportUseCase.execute()

            sourceAirportText = report.airportCoordinates.source.description
            destinationAirportText = report.airportCoordinates.destination.description
            observations = report.observations
            airportDistanceMiles = report.airportDistanceMiles
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
