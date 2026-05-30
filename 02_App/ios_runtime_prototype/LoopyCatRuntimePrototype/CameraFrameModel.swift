import AVFoundation
import CoreImage
import SwiftUI

final class CameraFrameModel: NSObject, ObservableObject {
    @Published var currentFrame: CGImage?
    @Published var status = "IDLE"
    @Published var frameCount = 0

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "loopycat.camera.session")
    private let videoQueue = DispatchQueue(label: "loopycat.camera.video")
    private let ciContext = CIContext()
    private var isConfigured = false

    func start() {
        status = "REQUESTING_CAMERA"

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStart()
                    } else {
                        self?.status = "CAMERA_DENIED"
                    }
                }
            }
        default:
            status = "CAMERA_DENIED"
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if !self.isConfigured {
                do {
                    try self.configureSession()
                    self.isConfigured = true
                } catch {
                    DispatchQueue.main.async {
                        self.status = "CAMERA_CONFIG_FAILED"
                    }
                    return
                }
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }

            DispatchQueue.main.async {
                self.status = "CAMERA_RUNNING"
            }
        }
    }

    private func configureSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.noBackCamera
        }

        let input = try AVCaptureDeviceInput(device: camera)
        guard session.canAddInput(input) else {
            throw CameraError.cannotAddInput
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(self, queue: videoQueue)

        guard session.canAddOutput(output) else {
            throw CameraError.cannotAddOutput
        }
        session.addOutput(output)

        if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = .portrait
        }

        session.commitConfiguration()
    }
}

extension CameraFrameModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }

        DispatchQueue.main.async {
            self.currentFrame = cgImage
            self.frameCount += 1
        }
    }
}

enum CameraError: Error {
    case noBackCamera
    case cannotAddInput
    case cannotAddOutput
}
