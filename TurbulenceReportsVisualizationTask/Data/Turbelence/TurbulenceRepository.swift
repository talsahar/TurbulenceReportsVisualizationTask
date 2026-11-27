import Foundation

protocol TurbulenceRepository {
    func fetchObservations() async throws -> [TurbulenceObservation]
}
