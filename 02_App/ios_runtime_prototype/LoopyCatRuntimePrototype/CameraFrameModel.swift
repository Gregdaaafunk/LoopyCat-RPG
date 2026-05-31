import AVFoundation
import CoreImage
import SwiftUI

final class CameraFrameModel: NSObject, ObservableObject {
    var frameHandler: ((CGImage, CGImagePropertyOrientation, CGSize, Date) -> Void)?

    @Published var currentFrame: CGImage?
    @Published var status = "IDLE"
    @Published var frameCount = 0
    @Published var frameReceived = false
    @Published var frameSize = CGSize.zero
    @Published var permissionState = "UNKNOWN"
    @Published var lastError = ""
    @Published var lastFrameDate: Date?
    @Published var currentOrientation = CGImagePropertyOrientation.right
    @Published var currentVideoOrientation = AVCaptureVideoOrientation.portrait
    @Published var currentZoomFactor: CGFloat = 1.0

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "loopycat.camera.session")
    private let videoQueue = DispatchQueue(label: "loopycat.camera.video")
    private let ciContext = CIContext()
    private var isConfigured = false
    private var output: AVCaptureVideoDataOutput?
    private var cameraPosition: AVCaptureDevice.Position = .back
    private var activeCameraDevice: AVCaptureDevice?

    func start() {
        status = "REQUESTING_CAMERA"
        permissionState = permissionDescription(for: AVCaptureDevice.authorizationStatus(for: .video))

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionState = granted ? "AUTHORIZED" : "DENIED"
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
        status = "IDLE"
    }

    func updateOrientation(_ interfaceOrientation: UIInterfaceOrientation) {
        let videoOrientation: AVCaptureVideoOrientation
        switch interfaceOrientation {
        case .portrait:
            videoOrientation = .portrait
            currentOrientation = .right
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
            currentOrientation = .left
        case .landscapeLeft:
            videoOrientation = .landscapeLeft
            currentOrientation = .up
        case .landscapeRight:
            videoOrientation = .landscapeRight
            currentOrientation = .down
        default:
            videoOrientation = .portrait
            currentOrientation = .right
        }
        currentVideoOrientation = videoOrientation

        sessionQueue.async { [weak self] in
            guard let self, let outputConnection = self.output?.connection(with: .video) else { return }
            if outputConnection.isVideoOrientationSupported {
                outputConnection.videoOrientation = videoOrientation
            }
        }
    }

    func resetZoom() {
        setZoomFactor(1.0)
    }

    func setZoomFactor(_ zoomFactor: CGFloat) {
        let clamped = max(1.0, zoomFactor)
        sessionQueue.async { [weak self] in
            guard let self, let device = self.activeCameraDevice else { return }
            let appliedZoom = max(1.0, min(clamped, device.activeFormat.videoMaxZoomFactor))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = appliedZoom
                device.unlockForConfiguration()
                DispatchQueue.main.async {
                    self.currentZoomFactor = appliedZoom
                }
            } catch {
                DispatchQueue.main.async {
                    self.lastError = error.localizedDescription
                }
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
                        self.lastError = error.localizedDescription
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
        cameraPosition = .back
        activeCameraDevice = camera

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
        self.output = output

        if let connection = output.connection(with: .video), connection.isVideoOrientationSupported {
            connection.videoOrientation = currentVideoOrientation
        }

        do {
            try camera.lockForConfiguration()
            camera.videoZoomFactor = 1.0
            camera.unlockForConfiguration()
            DispatchQueue.main.async {
                self.currentZoomFactor = 1.0
            }
        } catch {
            throw error
        }

        session.commitConfiguration()
    }

    private func permissionDescription(for status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "AUTHORIZED"
        case .notDetermined:
            return "NOT_DETERMINED"
        case .denied:
            return "DENIED"
        case .restricted:
            return "RESTRICTED"
        @unknown default:
            return "UNKNOWN"
        }
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

        let timestamp = Date()
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let orientation = currentOrientation

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.currentFrame = cgImage
            self.frameCount += 1
            self.frameReceived = true
            self.frameSize = size
            self.lastFrameDate = timestamp
            self.status = "CAMERA_RUNNING"
            self.frameHandler?(cgImage, orientation, size, timestamp)
        }
    }
}

enum CameraError: Error {
    case noBackCamera
    case cannotAddInput
    case cannotAddOutput
}
