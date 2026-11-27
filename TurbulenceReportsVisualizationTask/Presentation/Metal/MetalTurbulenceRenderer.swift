
import MetalKit

struct Vertex {
    var position: SIMD2<Float>
    var color: SIMD4<Float>
}

final class MetalTurbulenceRenderer: NSObject, MTKViewDelegate {

    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState

    private let verticalLineCount: Int
    private let horizontalLineCount: Int

    private var gridVertexBuffer: MTLBuffer?
    private var gridVertexCount = 0

    private var axisVertexStart = 0
    private var axisVertexCount = 0

    private var observationVertexBuffer: MTLBuffer?
    private var observationVertexCount = 0

    private var observations: [TurbulenceReportObservation] = []
    private var drawableSize: CGSize

    init(
        device: MTLDevice,
        verticalLineCount: Int,
        horizontalLineCount: Int,
        drawableSize: CGSize
    ) {
        self.device = device
        self.verticalLineCount = verticalLineCount
        self.horizontalLineCount = horizontalLineCount
        self.drawableSize = drawableSize

        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Could not create command queue")
        }
        self.commandQueue = commandQueue

        guard
            let library = device.makeDefaultLibrary(),
            let vertexFunction = library.makeFunction(name: "vertex_main"),
            let fragmentFunction = library.makeFunction(name: "fragment_main")
        else {
            fatalError("Could not load Metal shader functions")
        }

        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        do {
            pipelineState = try device.makeRenderPipelineState(
                descriptor: descriptor
            )
        } catch {
            fatalError("Pipeline creation failed: \(error)")
        }

        super.init()

        updateGeometry(drawableSize: drawableSize)
    }

    private func updateGeometry(drawableSize: CGSize) {
        self.drawableSize = drawableSize

        gridVertexBuffer = nil
        gridVertexCount = 0
        axisVertexStart = 0
        axisVertexCount = 0

        guard drawableSize.width > 0,
              drawableSize.height > 0 else {
            observationVertexBuffer = nil
            observationVertexCount = 0
            return
        }

        let geometry = VertexFactory.makeAllVertices(
            verticalLineCount: verticalLineCount,
            horizontalLineCount: horizontalLineCount,
            drawableSize: drawableSize
        )

        guard !geometry.vertices.isEmpty,
              let buffer = device.makeBuffer(
                  bytes: geometry.vertices,
                  length: MemoryLayout<Vertex>.stride * geometry.vertices.count,
                  options: .storageModeShared
              ) else {
            updateObservationGeometry()
            return
        }

        gridVertexBuffer = buffer
        gridVertexCount = geometry.gridCount
        axisVertexStart = geometry.gridCount
        axisVertexCount = geometry.axisCount

        updateObservationGeometry()
    }

    private func updateObservationGeometry() {
        observationVertexBuffer = nil
        observationVertexCount = 0

        guard drawableSize.width > 0,
              drawableSize.height > 0,
              !observations.isEmpty else {
            return
        }

        let vertices = VertexFactory.makeTurbulenceVertices(
            observations: observations,
            drawableSize: drawableSize
        )

        guard !vertices.isEmpty,
              let buffer = device.makeBuffer(
                  bytes: vertices,
                  length: MemoryLayout<Vertex>.stride * vertices.count,
                  options: .storageModeShared
              ) else {
            return
        }

        observationVertexBuffer = buffer
        observationVertexCount = vertices.count
    }

    func updateObservations(_ observations: [TurbulenceReportObservation]) {
        self.observations = observations
        updateObservationGeometry()
    }

    func draw(in view: MTKView) {
        guard
            let gridVertexBuffer,
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: descriptor
            )
        else {
            return
        }

        encoder.setRenderPipelineState(pipelineState)

        encoder.setVertexBuffer(
            gridVertexBuffer,
            offset: 0,
            index: 0
        )

        // Draw grid
        if gridVertexCount > 0 {
            encoder.drawPrimitives(
                type: .line,
                vertexStart: 0,
                vertexCount: gridVertexCount
            )
        }

        // Draw axes
        if axisVertexCount > 0 {
            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: axisVertexStart,
                vertexCount: axisVertexCount
            )
        }

        // Draw observations
        if let observationVertexBuffer,
           observationVertexCount > 0 {
            encoder.setVertexBuffer(
                observationVertexBuffer,
                offset: 0,
                index: 0
            )

            encoder.drawPrimitives(
                type: .triangle,
                vertexStart: 0,
                vertexCount: observationVertexCount
            )
        }

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        updateGeometry(drawableSize: size)
    }
}
