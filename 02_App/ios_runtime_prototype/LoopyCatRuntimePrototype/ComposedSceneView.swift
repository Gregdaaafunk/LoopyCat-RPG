import SwiftUI
import UIKit

struct ComposedSceneView: View {
    let cameraImage: CGImage?
    let debug: DebugSnapshot
    let cameraStatus: String
    let includeDebug: Bool

    var body: some View {
        ZStack {
            CameraFrameView(cameraImage: cameraImage, cameraStatus: cameraStatus)
            OverlayLayerView()

            if includeDebug {
                DebugPanelView(debug: debug, cameraStatus: cameraStatus)
                    .padding(.top, 48)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .background(.black)
    }
}

struct CameraFrameView: View {
    let cameraImage: CGImage?
    let cameraStatus: String

    var body: some View {
        GeometryReader { proxy in
            if let cameraImage {
                Image(uiImage: UIImage(cgImage: cameraImage, scale: 1.0, orientation: .right))
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            } else {
                ZStack {
                    Color.black
                    Text(cameraStatus)
                        .font(.headline.monospaced())
                        .foregroundStyle(.white)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}

struct OverlayLayerView: View {
    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width * 0.5, y: proxy.size.height * 0.45)

            ZStack {
                portalPlaceholder(center: center)
                bossPlaceholder(center: center)
                hud
            }
        }
        .allowsHitTesting(false)
    }

    private func portalPlaceholder(center: CGPoint) -> some View {
        ZStack {
            Circle()
                .stroke(.cyan.opacity(0.9), lineWidth: 4)
                .frame(width: 150, height: 150)
            Circle()
                .stroke(.purple.opacity(0.7), style: StrokeStyle(lineWidth: 8, dash: [12, 10]))
                .frame(width: 190, height: 190)
            Text("TARGET LOCKED")
                .font(.caption.monospaced().bold())
                .foregroundStyle(.yellow)
                .offset(y: -120)
        }
        .position(center)
    }

    private func bossPlaceholder(center: CGPoint) -> some View {
        VStack(spacing: 6) {
            Text("BOSS")
                .font(.title.bold())
                .foregroundStyle(.white)
                .shadow(color: .red, radius: 8)
            RoundedRectangle(cornerRadius: 6)
                .fill(.red.opacity(0.85))
                .frame(width: 118, height: 92)
                .overlay {
                    Text("SPAWN")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.white)
                }
        }
        .position(x: center.x, y: center.y + 12)
    }

    private var hud: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LOOPYCAT RPG AR")
                        .font(.caption.monospaced().bold())
                    Text("HP")
                        .font(.caption2.monospaced())
                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.red)
                            .frame(width: proxy.size.width * 0.76)
                    }
                    .frame(width: 180, height: 10)
                    .background(.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .foregroundStyle(.white)
                Spacer()
                Text("COMBO x0")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.yellow)
            }
            Spacer()
            Text("PHOTO TEST: CAMERA + OVERLAY")
                .font(.caption.monospaced().bold())
                .foregroundStyle(.white)
                .padding(.bottom, 72)
        }
        .padding(.top, 8)
        .padding(.horizontal, 12)
    }
}
