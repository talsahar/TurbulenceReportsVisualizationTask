import SwiftUI

@main
struct TurbulenceReportsVisualizationTaskApp: App {

    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            dependencies.makeTurbulenceReportView()
        }
    }
}
