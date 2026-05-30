import SwiftUI

@main
struct LoopyCatRuntimePrototypeApp: App {
    @StateObject private var camera = CameraFrameModel()
    @StateObject private var debugState = DebugState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(camera)
                .environmentObject(debugState)
                .onAppear {
                    debugState.log("app_start")
                    camera.start()
                }
                .onDisappear {
                    camera.stop()
                }
        }
    }
}
