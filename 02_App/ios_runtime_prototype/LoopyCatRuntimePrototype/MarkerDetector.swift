import CoreImage
import Vision
import UIKit

final class RuntimeMarkerDetector {
    private let ciContext = CIContext()
    private let referenceFeaturePrint: VNFeaturePrintObservation?

    private(set) var processedFrameCount = 0
    private(set) var lastCandidateCount = 0
    private(set) var lastFailureReason = "UNINITIALIZED"
    private(set) var lastDetectionDate: Date?
    private(set) var referenceMarkerLoaded = false
    private(set) var referenceMarkerPath = "NONE"
    private(set) var referenceFeaturePrintReady = false
    private(set) var referenceFeaturePrintError = "UNINITIALIZED"

    init() {
        if let referenceURL = RuntimeMediaLibrary.resourceURL(named: "loopycat_arc_marker") ?? RuntimeMediaLibrary.resourceURL(named: "canonical_marker") {
            referenceMarkerLoaded = true
            referenceMarkerPath = referenceURL.path
            guard let referenceImage = UIImage(contentsOfFile: referenceURL.path)?.cgImage else {
                referenceFeaturePrint = nil
                referenceFeaturePrintError = "REFERENCE_MARKER_IMAGE_LOAD_FAILED"
                lastFailureReason = referenceFeaturePrintError
                return
            }

            let printResult = Self.generateFeaturePrint(for: referenceImage, context: CIContext())
            referenceFeaturePrint = printResult.featurePrint
            referenceFeaturePrintReady = printResult.featurePrint != nil
            referenceFeaturePrintError = printResult.error ?? "NONE"
            if !referenceFeaturePrintReady {
                lastFailureReason = referenceFeaturePrintError
            }
        } else {
            referenceFeaturePrint = nil
            referenceFeaturePrintError = "MISSING_MARKER_ASSET"
            lastFailureReason = referenceFeaturePrintError
        }
    }

    func detect(frame: CGImage, orientation: CGImagePropertyOrientation, timestamp: Date) -> RuntimeMarkerObservation? {
        processedFrameCount += 1
        guard let referenceFeaturePrint else {
            lastFailureReason = referenceFeaturePrintError == "NONE" ? "MISSING_REFERENCE_FEATURE_PRINT" : referenceFeaturePrintError
            return nil
        }

        let rectangleRequest = VNDetectRectanglesRequest()
        rectangleRequest.maximumObservations = 12
        rectangleRequest.minimumConfidence = 0.25
        rectangleRequest.minimumAspectRatio = 0.65
        rectangleRequest.maximumAspectRatio = 1.35
        rectangleRequest.quadratureTolerance = 30.0
        rectangleRequest.minimumSize = 0.06

        do {
            let handler = VNImageRequestHandler(cgImage: frame, orientation: orientation, options: [:])
            try handler.perform([rectangleRequest])
        } catch {
            lastFailureReason = "VISION_RECTANGLE_ERROR: \(error.localizedDescription)"
            return nil
        }

        let rectangles = rectangleRequest.results ?? []
        lastCandidateCount = rectangles.count

        let ciImage = CIImage(cgImage: frame).oriented(orientation)
        let extent = ciImage.extent

        var bestObservation: RuntimeMarkerObservation?
        var bestConfidence = 0.0

        for candidate in rectangles {
            guard let warped = Self.warpedImage(from: ciImage, rectangle: candidate) else { continue }
            guard let candidateCG = ciContext.createCGImage(warped, from: warped.extent) else { continue }
            let candidatePrintResult = Self.generateFeaturePrint(for: candidateCG, context: ciContext)
            guard let candidatePrint = candidatePrintResult.featurePrint else { continue }

            var distance: Float = 0
            do {
                try referenceFeaturePrint.computeDistance(&distance, to: candidatePrint)
            } catch {
                continue
            }

            let rectConfidence = Double(candidate.confidence)
            let featureConfidence = max(0.0, 1.0 - Double(distance) / 60.0)
            let combinedConfidence = (rectConfidence * 0.45) + (featureConfidence * 0.55)

            if combinedConfidence > bestConfidence {
                let center = candidate.boundingBox.centerPoint
                let scale = max(candidate.boundingBox.width, candidate.boundingBox.height)
                let rotation = atan2(candidate.topRight.y - candidate.topLeft.y, candidate.topRight.x - candidate.topLeft.x)
                let distanceEstimate = 1.0 / max(scale, 0.001)

                bestConfidence = combinedConfidence
                bestObservation = RuntimeMarkerObservation(
                    center: center,
                    boundingBox: candidate.boundingBox,
                    rotation: rotation,
                    scale: scale,
                    confidence: combinedConfidence,
                    distanceEstimate: distanceEstimate,
                    candidateCount: rectangles.count,
                    timestamp: timestamp,
                    sourceFrameSize: CGSize(width: extent.width, height: extent.height),
                    sourceOrientation: orientation.runtimeString,
                    failureReason: nil
                )
            }
        }

        if let bestObservation, bestObservation.confidence >= 0.30 {
            lastDetectionDate = timestamp
            lastFailureReason = "NONE"
            return bestObservation
        }

        if let scannedObservation = Self.scanForMarker(in: ciImage, referenceFeaturePrint: referenceFeaturePrint, context: ciContext, timestamp: timestamp) {
            lastCandidateCount = scannedObservation.candidateCount
            lastDetectionDate = timestamp
            lastFailureReason = "FEATURE_SCAN_MATCH"
            return scannedObservation
        }

        if rectangles.isEmpty {
            lastCandidateCount = 45
        }
        lastFailureReason = rectangles.isEmpty ? "NO_RECTANGLE_AND_NO_TILE_MATCH" : "NO_MATCH_ABOVE_CONFIDENCE_THRESHOLD"
        return nil
    }

    private static func warpedImage(from image: CIImage, rectangle: VNRectangleObservation) -> CIImage? {
        let extent = image.extent
        func vector(from point: CGPoint) -> CIVector {
            CIVector(
                x: point.x * extent.width,
                y: point.y * extent.height
            )
        }

        guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(vector(from: rectangle.topLeft), forKey: "inputTopLeft")
        filter.setValue(vector(from: rectangle.topRight), forKey: "inputTopRight")
        filter.setValue(vector(from: rectangle.bottomLeft), forKey: "inputBottomLeft")
        filter.setValue(vector(from: rectangle.bottomRight), forKey: "inputBottomRight")
        return filter.outputImage
    }

    private static func generateFeaturePrint(for image: CGImage, context: CIContext) -> (featurePrint: VNFeaturePrintObservation?, error: String?) {
        let request = VNGenerateImageFeaturePrintRequest()
        request.revision = VNGenerateImageFeaturePrintRequestRevision1
        do {
            let handler = VNImageRequestHandler(cgImage: image, orientation: .up, options: [:])
            try handler.perform([request])
            if let featurePrint = request.results?.first as? VNFeaturePrintObservation {
                return (featurePrint, nil)
            }
            return (nil, "FEATURE_PRINT_REQUEST_RETURNED_NO_RESULTS")
        } catch {
            return (nil, "FEATURE_PRINT_GENERATION_ERROR: \(error.localizedDescription)")
        }
    }

    private static func scanForMarker(
        in image: CIImage,
        referenceFeaturePrint: VNFeaturePrintObservation,
        context: CIContext,
        timestamp: Date
    ) -> RuntimeMarkerObservation? {
        let extent = image.extent
        let minSide = min(extent.width, extent.height)
        let scaleFractions: [CGFloat] = [0.26, 0.34, 0.46, 0.60, 0.76]
        let positionFractions: [CGFloat] = [0.25, 0.5, 0.75]

        var bestObservation: RuntimeMarkerObservation?
        var bestConfidence = 0.0
        var candidateCount = 0

        for scale in scaleFractions {
            let cropSide = minSide * scale
            guard cropSide > 80 else { continue }
            let half = cropSide * 0.5

            for xFraction in positionFractions {
                let centerX = extent.minX + extent.width * xFraction
                let x = min(max(centerX, extent.minX + half), extent.maxX - half)

                for yFraction in positionFractions {
                    let centerY = extent.minY + extent.height * yFraction
                    let y = min(max(centerY, extent.minY + half), extent.maxY - half)

                    let cropRect = CGRect(x: x - half, y: y - half, width: cropSide, height: cropSide)
                    let clippedRect = cropRect.intersection(extent)
                    guard !clippedRect.isNull, !clippedRect.isEmpty else { continue }
                    guard let cgImage = context.createCGImage(image.cropped(to: clippedRect), from: clippedRect) else {
                        continue
                    }

                    candidateCount += 1
                    let candidatePrintResult = Self.generateFeaturePrint(for: cgImage, context: context)
                    guard let candidatePrint = candidatePrintResult.featurePrint else { continue }

                    var distance: Float = 0
                    do {
                        try referenceFeaturePrint.computeDistance(&distance, to: candidatePrint)
                    } catch {
                        continue
                    }

                    let featureConfidence = max(0.0, 1.0 - Double(distance) / 45.0)
                    let combinedConfidence = featureConfidence * 0.82 + Double(scale) * 0.18
                    guard combinedConfidence > bestConfidence else { continue }

                    let normalizedRect = CGRect(
                        x: clippedRect.minX / extent.width,
                        y: clippedRect.minY / extent.height,
                        width: clippedRect.width / extent.width,
                        height: clippedRect.height / extent.height
                    )
                    let center = normalizedRect.centerPoint

                    bestConfidence = combinedConfidence
                    bestObservation = RuntimeMarkerObservation(
                        center: center,
                        boundingBox: normalizedRect,
                        rotation: 0,
                        scale: scale,
                        confidence: combinedConfidence,
                        distanceEstimate: 1.0 / max(scale, 0.001),
                        candidateCount: candidateCount,
                        timestamp: timestamp,
                        sourceFrameSize: CGSize(width: extent.width, height: extent.height),
                        sourceOrientation: "feature_scan",
                        failureReason: nil
                    )
                }
            }
        }

        if var bestObservation, bestObservation.confidence >= 0.34 {
            bestObservation.candidateCount = candidateCount
            return bestObservation
        }
        return nil
    }
}
