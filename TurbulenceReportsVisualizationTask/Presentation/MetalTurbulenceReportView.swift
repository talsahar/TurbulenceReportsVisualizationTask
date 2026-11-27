
import SwiftUI
import MetalKit

struct MetalTurbulenceReportView: UIViewRepresentable {

    let observations: [TurbulenceReportObservation]
    let verticalLineCount: Int
    let horizontalLineCount: Int

    final class Coordinator {
        var renderer: MetalTurbulenceRenderer?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MTKView {
        guard let device = MTLCreateSystemDefaultDevice() else {
            return MTKView(frame: .zero)
        }

        let view = MTKView(frame: .zero, device: device)

        view.clearColor = MTLClearColor(
            red: 16 / 255.0,
            green: 24 / 255.0,
            blue: 35 / 255.0,
            alpha: 1.0
        )

        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = true
        view.isPaused = true
        view.enableSetNeedsDisplay = true

        let renderer = MetalTurbulenceRenderer(
            device: device,
            verticalLineCount: verticalLineCount,
            horizontalLineCount: horizontalLineCount,
            drawableSize: view.drawableSize
        )

        context.coordinator.renderer = renderer
        view.delegate = renderer

        renderer.updateObservations(observations)
        view.setNeedsDisplay()

        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        guard let renderer = context.coordinator.renderer else {
            return
        }

        renderer.updateObservations(observations)
        uiView.setNeedsDisplay()
    }
}
