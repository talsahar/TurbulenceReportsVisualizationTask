import Foundation

/// A single turbulence observation from the data source.
struct TurbulenceObservationDTO: Codable, Hashable, Sendable {
    /// H3 hexagonal cell identifier.
    let h3Hex: String
    /// Unix timestamp (seconds since 1970-01-01 UTC).
    let ts: Int
    /// Turbulence severity (0 = none/light, 4 = severe).
    let sev: Int
    /// Altitude in feet.
    let altFt: Int
}
