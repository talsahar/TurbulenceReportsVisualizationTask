import Foundation

protocol TurbulenceDataProvider {
    func allObservations() throws -> [TurbulenceObservationDTO]
}

struct LocalJSONTurbulenceDataProvider: TurbulenceDataProvider {
    
    enum ProviderError: Error, LocalizedError {
        
        case fileNotFound(name: String)
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let name):
                return "Turbulence data file not found: \(name)"
            }
        }
    }
    
    private let fileURL: URL
    
    init(
        fileName: String = "turb",
        fileExtension: String = "json",
        bundle: Bundle = .main
    ) throws {
        guard let url = bundle.url(
            forResource: fileName,
            withExtension: fileExtension
        ) else {
            throw ProviderError.fileNotFound(
                name: "\(fileName).\(fileExtension)"
            )
        }
        
        self.fileURL = url
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func allObservations() throws -> [TurbulenceObservationDTO] {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(
            [TurbulenceObservationDTO].self,
            from: data
        )
    }
}
