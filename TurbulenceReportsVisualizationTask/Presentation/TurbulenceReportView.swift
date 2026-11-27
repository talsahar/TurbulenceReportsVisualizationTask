
import SwiftUI

struct TurbulenceReportView: View {

    @State private var viewModel: TurbulenceReportViewModel

    init(viewModel: TurbulenceReportViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.chartBackground
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                }

                chartContent
            }
            .padding()
        }
        .task {
            await viewModel.fetchData()
        }
    }

    private var chartContent: some View {
        let flightLevelLabels = viewModel.flightLevelAxisLabels
        let distanceLabels = viewModel.distanceAxisLabels

        return VStack {
            HStack(alignment: .top) {
                flightLevelAxis(labels: flightLevelLabels)
                    .padding(.bottom, 10)
                    .padding(.top, -5)

                VStack(spacing: 4) {
                    MetalTurbulenceReportView(
                        observations: viewModel.observations,
                        verticalLineCount: max(distanceLabels.count - 1, 0),
                        horizontalLineCount: max(flightLevelLabels.count - 1, 0)
                    )

                    distanceAxis(labels: distanceLabels)
                }
            }

            airportLabels
        }
    }

    private func errorView(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.red)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var airportLabels: some View {
        HStack {
            if let source = viewModel.sourceAirportText {
                Text(source)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let destination = viewModel.destinationAirportText {
                Text(destination)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .font(.caption)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func flightLevelAxis(labels: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(.white)

                if index != labels.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func distanceAxis(labels: [Int]) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach(Array(labels.enumerated()), id: \.offset) { index, distance in
                    let progress = labels.count > 1
                        ? CGFloat(index) / CGFloat(labels.count - 1)
                        : 0

                    Text("\(distance) mi")
                        .font(.system(size: 9))
                        .foregroundStyle(.white)
                        .fixedSize()
                        .position(
                            x: geometry.size.width * progress,
                            y: geometry.size.height / 2
                        )
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
