import XCTest
@testable import TurbulenceReportsVisualizationTask

final class TurbulenceDataProviderTests: XCTestCase {

    // MARK: - Helpers

    private func makeTempJSONFile(observations: [TurbulenceObservationDTO]) throws -> URL {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("turb_test_\(UUID().uuidString).json")

        let data = try JSONEncoder().encode(observations)
        try data.write(to: fileURL)
        return fileURL
    }

    private let sample: [TurbulenceObservationDTO] = [
        TurbulenceObservationDTO(h3Hex: "8529a887fffffff", ts: 1742457290, sev: 0, altFt: 37000),
        TurbulenceObservationDTO(h3Hex: "852a9033fffffff", ts: 1742467491, sev: 1, altFt: 21000),
        TurbulenceObservationDTO(h3Hex: "85489a9bfffffff", ts: 1742466951, sev: 3, altFt: 36000),
        TurbulenceObservationDTO(h3Hex: "852a866ffffffff", ts: 1742464959, sev: 2, altFt: 28000),
        TurbulenceObservationDTO(h3Hex: "8529a083fffffff", ts: 1742453771, sev: 4, altFt: 21000)
    ]

    // MARK: - Tests

    /// Verifies that loading the same data multiple times returns identical results
    /// (cache hit / same object load).
    func testSameObjectLoad() throws {
        let fileURL = try makeTempJSONFile(observations: sample)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let provider = LocalJSONTurbulenceDataProvider(fileURL: fileURL)

        let first  = try provider.allObservations()
        let second = try provider.allObservations()
        let third  = try provider.allObservations()

        // Same content
        XCTAssertEqual(first, second)
        XCTAssertEqual(second, third)

        // Same count and values
        XCTAssertEqual(first.count, sample.count)
        XCTAssertEqual(first, sample)
    }

    func testLoadFromRealFileIfPresent() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "turb", withExtension: "json") else {
            throw XCTSkip("turb.json not present in test bundle")
        }

        let provider = LocalJSONTurbulenceDataProvider(fileURL: url)

        let first  = try provider.allObservations()
        let second = try provider.allObservations()

        XCTAssertFalse(first.isEmpty)
        XCTAssertEqual(first, second, "Repeated loads of the real file must return identical data")
    }
}
