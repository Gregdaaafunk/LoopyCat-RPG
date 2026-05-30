import Foundation

final class DebugState: ObservableObject {
    @Published var trackingState = "SEARCH"
    @Published var bossState = "NONE"
    @Published var combatState = "IDLE"
    @Published var recordingState = "READY"
    @Published var cameraStatus = "IDLE"
    @Published var eventLog: [String] = []

    var snapshot: DebugSnapshot {
        DebugSnapshot(
            trackingState: trackingState,
            bossState: bossState,
            combatState: combatState,
            recordingState: recordingState,
            cameraStatus: cameraStatus,
            eventLog: Array(eventLog.suffix(6))
        )
    }

    func log(_ message: String) {
        let stamp = ISO8601DateFormatter().string(from: Date())
        eventLog.append("\(stamp) \(message)")
        if eventLog.count > 50 {
            eventLog.removeFirst(eventLog.count - 50)
        }
    }
}

struct DebugSnapshot {
    let trackingState: String
    let bossState: String
    let combatState: String
    let recordingState: String
    let cameraStatus: String
    let eventLog: [String]
}
