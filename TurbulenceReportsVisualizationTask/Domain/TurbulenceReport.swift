struct TurbulenceReport: Sendable {
    let observations: [TurbulenceReportObservation]
    let airportCoordinates: AirportCoordinates
    let airportDistanceMiles: Double /// Distance between source and destination airports in statute miles.
}

struct TurbulenceReportObservation: Sendable {

    enum Severity: Int, Sendable {
        case none = 0
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }
    
    let flightLevel: Int /// Flight level derived from altitude in feet divided by 100.
    let severity: Severity
    let normalizedDistance: Float /// Normalized distance along the flight route (0...1).
}
