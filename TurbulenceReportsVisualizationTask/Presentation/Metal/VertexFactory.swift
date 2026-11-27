
import CoreGraphics

struct VertexFactory {

    // MARK: - Grid

    private static let gridColor = SIMD4<Float>(0.25, 0.30, 0.36, 1.0)
    private static let axisColor = SIMD4<Float>(1, 1, 1, 1)

    static func makeGridVertices(
        verticalLineCount: Int,
        horizontalLineCount: Int
    ) -> [Vertex] {
        var vertices: [Vertex] = []

        // Horizontal lines
        if horizontalLineCount > 0 {
            for index in 0...horizontalLineCount {
                let y = gridCoordinate(index: index, count: horizontalLineCount)

                vertices.append(
                    Vertex(position: SIMD2(-1, y), color: gridColor)
                )
                vertices.append(
                    Vertex(position: SIMD2(1, y), color: gridColor)
                )
            }
        }

        // Vertical lines
        if verticalLineCount > 0 {
            for index in 0...verticalLineCount {
                let x = gridCoordinate(index: index, count: verticalLineCount)

                vertices.append(
                    Vertex(position: SIMD2(x, -1), color: gridColor)
                )
                vertices.append(
                    Vertex(position: SIMD2(x, 1), color: gridColor)
                )
            }
        }

        // Top boundary
        vertices += makeLineVertices(
            from: SIMD2(-0.995, 0.995),
            to: SIMD2(0.995, 0.995),
            color: gridColor
        )

        // Left boundary
        vertices += makeLineVertices(
            from: SIMD2(-0.995, 0.995),
            to: SIMD2(-0.995, -0.995),
            color: gridColor
        )

        return vertices
    }

    private static func gridCoordinate(
        index: Int,
        count: Int
    ) -> Float {
        -1.0 + 2.0 * Float(index) / Float(count)
    }

    private static func makeLineVertices(
        from start: SIMD2<Float>,
        to end: SIMD2<Float>,
        color: SIMD4<Float>
    ) -> [Vertex] {
        [
            Vertex(position: start, color: color),
            Vertex(position: end, color: color)
        ]
    }

    // MARK: - All Vertices

    static func makeAllVertices(
        verticalLineCount: Int,
        horizontalLineCount: Int,
        drawableSize: CGSize
    ) -> (
        vertices: [Vertex],
        gridCount: Int,
        axisCount: Int
    ) {
        var vertices = makeGridVertices(
            verticalLineCount: verticalLineCount,
            horizontalLineCount: horizontalLineCount
        )

        let gridCount = vertices.count

        vertices += makeAxisVertices(drawableSize: drawableSize)

        return (
            vertices: vertices,
            gridCount: gridCount,
            axisCount: vertices.count - gridCount
        )
    }

    // MARK: - Axes

    private static func makeAxisVertices(
        drawableSize: CGSize,
        thickness: Float = 4
    ) -> [Vertex] {
        guard isValid(drawableSize) else {
            return []
        }

        let xThickness = pixelThickness(
            thickness,
            drawableLength: drawableSize.width
        )

        let yThickness = pixelThickness(
            thickness,
            drawableLength: drawableSize.height
        )

        var vertices: [Vertex] = []

        // Horizontal X axis
        vertices += makeRectangleVertices(
            min: SIMD2(-1, -1),
            max: SIMD2(1, -1 + yThickness),
            color: axisColor
        )

        // Vertical Y axis
        vertices += makeRectangleVertices(
            min: SIMD2(-1, -1),
            max: SIMD2(-1 + xThickness, 1),
            color: axisColor
        )

        return vertices
    }

    private static func pixelThickness(
        _ thickness: Float,
        drawableLength: CGFloat
    ) -> Float {
        2.0 * thickness / Float(drawableLength)
    }

    // MARK: - Turbulence Observations

    static func makeTurbulenceVertices(
        observations: [TurbulenceReportObservation],
        drawableSize: CGSize
    ) -> [Vertex] {
        guard isValid(drawableSize) else {
            return []
        }

        let maxFL = Float(Constants.turbulenceReportMaxFL)

        // Each marker represents 10 flight levels vertically.
        let halfHeight = Constants.turbulenceReportSquarePixelSize / 2 / maxFL

        // Compensate for drawable aspect ratio to preserve square markers.
        let aspectRatio = Float(drawableSize.height / drawableSize.width)
        let halfWidth = halfHeight * aspectRatio

        return observations.flatMap { observation in
            let center = SIMD2(
                observation.normalizedDistance * 2.0 - 1.0,
                Float(observation.flightLevel) / maxFL * 2.0 - 1.0
            )

            return makeRectangleVertices(
                min: SIMD2(
                    center.x - halfWidth,
                    center.y - halfHeight
                ),
                max: SIMD2(
                    center.x + halfWidth,
                    center.y + halfHeight
                ),
                color: severityColor(observation.severity)
            )
        }
    }

    // MARK: - Rectangle

    private static func makeRectangleVertices(
        min: SIMD2<Float>,
        max: SIMD2<Float>,
        color: SIMD4<Float>
    ) -> [Vertex] {
        let bottomLeft = SIMD2(min.x, min.y)
        let bottomRight = SIMD2(max.x, min.y)
        let topLeft = SIMD2(min.x, max.y)
        let topRight = SIMD2(max.x, max.y)

        return [
            Vertex(position: bottomLeft, color: color),
            Vertex(position: bottomRight, color: color),
            Vertex(position: topLeft, color: color),

            Vertex(position: topLeft, color: color),
            Vertex(position: bottomRight, color: color),
            Vertex(position: topRight, color: color)
        ]
    }

    // MARK: - Severity Colors

    private static func severityColor(
        _ severity: TurbulenceReportObservation.Severity
    ) -> SIMD4<Float> {
        switch severity {
        case .none:
            SIMD4<Float>(137, 137, 137, 255) / 255.0
        case .low:
            SIMD4<Float>(255, 240, 76, 255) / 255.0
        case .medium:
            SIMD4<Float>(255, 188, 9, 255) / 255.0
        case .high:
            SIMD4<Float>(255, 113, 0, 255) / 255.0
        case .critical:
            SIMD4<Float>(255, 0, 0, 255) / 255.0
        }
    }

    // MARK: - Validation

    private static func isValid(_ drawableSize: CGSize) -> Bool {
        drawableSize.width > 0 && drawableSize.height > 0
    }
}
