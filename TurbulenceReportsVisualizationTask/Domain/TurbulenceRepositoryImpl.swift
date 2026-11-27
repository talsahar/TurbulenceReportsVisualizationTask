struct TurbulenceRepositoryImpl: TurbulenceRepository {
    let h3Coordinator: H3Coordinating
    let dataProvider: TurbulenceDataProvider

    init(
        h3Coordinator: H3Coordinating,
        dataProvider: TurbulenceDataProvider
    ) {
        self.h3Coordinator = h3Coordinator
        self.dataProvider = dataProvider
    }

    func fetchObservations() async throws -> [TurbulenceObservation] {
        let observations = try dataProvider.allObservations()

        var result: [TurbulenceObservation] = []
        result.reserveCapacity(observations.count)

        for observation in observations {
            let coordinate = await h3Coordinator.coordinate(for: observation.h3Hex)

            result.append(
                TurbulenceObservation(
                    coordinate: coordinate,
                    timestamp: observation.ts,
                    severity: observation.sev,
                    altitudeFeet: observation.altFt
                )
            )
        }

        return result
    }
}
