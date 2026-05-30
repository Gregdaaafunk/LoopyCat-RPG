import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var camera: CameraFrameModel
    @EnvironmentObject private var debugState: DebugState
    @State private var isSavingPhoto = false
    @State private var photoStatus = "PHOTO READY"

    var body: some View {
        ZStack {
            ComposedSceneView(
                cameraImage: camera.currentFrame,
                debug: debugState.snapshot,
                cameraStatus: camera.status,
                includeDebug: true
            )
            .ignoresSafeArea()

            VStack {
                Spacer()
                controls
            }
            .padding()
        }
        .onChange(of: camera.status) { newValue in
            debugState.cameraStatus = newValue
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button {
                capturePhoto()
            } label: {
                Text(isSavingPhoto ? "SAVING..." : "PHOTO")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isSavingPhoto || camera.currentFrame == nil)

            Text(photoStatus)
                .font(.caption.monospaced())
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func capturePhoto() {
        isSavingPhoto = true
        photoStatus = "CAPTURING"
        debugState.recordingState = "CAPTURING_PHOTO"
        debugState.log("recording_started PHOTO")

        Task { @MainActor in
            let content = ComposedSceneView(
                cameraImage: camera.currentFrame,
                debug: debugState.snapshot,
                cameraStatus: camera.status,
                includeDebug: true
            )
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            let renderer = ImageRenderer(content: content)
            renderer.scale = UIScreen.main.scale

            guard let image = renderer.uiImage else {
                photoStatus = "CAPTURE FAILED"
                debugState.recordingState = "FAILED"
                debugState.log("recording_failed image_renderer_empty")
                isSavingPhoto = false
                return
            }

            do {
                debugState.recordingState = "EXPORTING"
                try await PhotoLibraryWriter.save(image)
                photoStatus = "SAVED TO PHOTOS"
                debugState.recordingState = "FINISHED"
                debugState.log("recording_finished PHOTO composed=true")
            } catch {
                photoStatus = "SAVE FAILED"
                debugState.recordingState = "FAILED"
                debugState.log("recording_failed \(error.localizedDescription)")
            }

            isSavingPhoto = false
        }
    }
}
