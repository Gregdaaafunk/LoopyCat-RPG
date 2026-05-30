import SwiftUI

@main
struct LoopyCatRuntimePrototypeApp: App {
    @StateObject private var runtime = RuntimeSessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(runtime)
        }
    }
}
