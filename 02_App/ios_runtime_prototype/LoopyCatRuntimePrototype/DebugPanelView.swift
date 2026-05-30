import SwiftUI

struct DebugPanelView: View {
    let debug: DebugSnapshot
    let cameraStatus: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("DEBUG")
                .font(.caption.monospaced().bold())
                .foregroundStyle(.yellow)
            row("camera", cameraStatus)
            row("tracking", debug.trackingState)
            row("boss", debug.bossState)
            row("combat", debug.combatState)
            row("recording", debug.recordingState)
            Divider().background(.white.opacity(0.5))
            ForEach(debug.eventLog, id: \.self) { event in
                Text(event)
                    .lineLimit(1)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(10)
        .background(.black.opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(maxWidth: 330, alignment: .leading)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.68))
                .frame(width: 76, alignment: .leading)
            Text(value)
                .font(.caption2.monospaced().bold())
                .foregroundStyle(.white)
        }
    }
}
