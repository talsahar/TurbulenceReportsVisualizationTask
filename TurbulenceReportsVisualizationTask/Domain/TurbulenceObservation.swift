
import CoreLocation

struct TurbulenceObservation: Sendable {
    let coordinate: CLLocationCoordinate2D
    /// Unix timestamp (seconds since 1970-01-01 UTC).
    let timestamp: Int
    /// Turbulence severity (0 = none/light, 4 = severe).
    let severity: Int
    /// Altitude in feet.
    let altitudeFeet: Int
}
