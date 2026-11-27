
import Foundation

protocol AirportCoordinatesProvider {
    func fetchCoordinates() async throws -> AirportCoordinates
}

struct AirportCoordinatesJSONProvider: AirportCoordinatesProvider {

    enum ProviderError: Error, LocalizedError {
        case fileNotFound(name: String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let name):
                return "Airport coordinates file not found: \(name)"
            }
        }
    }

    private let fileURL: URL

    init(
        resource: String = "AirportCoordinates",
        fileExtension: String = "json",
        bundle: Bundle = .main
    ) throws {
        guard let url = bundle.url(
            forResource: resource,
            withExtension: fileExtension
        ) else {
            throw ProviderError.fileNotFound(
                name: "\(resource).\(fileExtension)"
            )
        }

        self.fileURL = url
    }

    func fetchCoordinates() async throws -> AirportCoordinates {
        let data = try Data(contentsOf: fileURL)

        return try JSONDecoder().decode(
            AirportCoordinates.self,
            from: data
        )
    }
}
