import SwiftUI

@MainActor
final class AppDependencies {
    
    private func makeTurbulenceRepository() -> TurbulenceRepository {
        TurbulenceRepositoryImpl(
            h3Coordinator: H3Coordinator(cache: H3Cache()),
            dataProvider: try! LocalJSONTurbulenceDataProvider()
        )
    }
    
    private func makeTurbulenceReportViewModel() -> TurbulenceReportViewModel {
        let prepareTurbulenceReportUseCase = PrepareTurbulenceReportUseCaseImpl(
            turbulenceRepository: makeTurbulenceRepository(),
            airportCoordinatesProvider: try! AirportCoordinatesJSONProvider(),
            filteringService: TurbulenceObservationFilteringService(),
            distanceCalculator: DistanceCalculator()
        )
        return TurbulenceReportViewModel(
            prepareTurbulenceReportUseCase: prepareTurbulenceReportUseCase
        )
    }
    
    func makeTurbulenceReportView() -> some View {
        TurbulenceReportView(viewModel: makeTurbulenceReportViewModel())
    }
}
