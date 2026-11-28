import CoreLocation

struct TurbulenceReportMapper {

    static func map(
        observations: [TurbulenceObservation],
        sourceCoordinate: CLLocationCoordinate2D,
        airportDistanceMiles: Double
    ) -> [TurbulenceReportObservation] {

        let validObservations = observations.filter {
            TurbulenceReportObservation.Severity(
                rawValue: $0.severity
            ) != nil
        }

        let filteredObservations = TurbulenceObservationFilteringService
            .keepLatestObservationPerCoordinate(
                from: validObservations
            )

        return filteredObservations.compactMap {
            mapObservation(
                $0,
                sourceCoordinate: sourceCoordinate,
                airportDistanceMiles: airportDistanceMiles
            )
        }
    }

    private static func mapObservation(
        _ observation: TurbulenceObservation,
        sourceCoordinate: CLLocationCoordinate2D,
        airportDistanceMiles: Double
    ) -> TurbulenceReportObservation? {

        guard let severity = TurbulenceReportObservation.Severity(
            rawValue: observation.severity
        ) else {
            return nil
        }

        let normalizedDistance = normalizedDistance(
            from: sourceCoordinate,
            to: observation.coordinate,
            totalDistance: airportDistanceMiles
        )

        return TurbulenceReportObservation(
            flightLevel: observation.altitudeFeet / 100,
            severity: severity,
            normalizedDistance: normalizedDistance
        )
    }

    private static func normalizedDistance(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        totalDistance: Double
    ) -> Float {

        let distance = DistanceCalculator.distanceInMiles(
            from: origin,
            to: destination
        )

        guard distance.isFinite else {
            return 0
        }

        return Float(
            min(max(distance / totalDistance, 0), 1)
        )
    }
}
