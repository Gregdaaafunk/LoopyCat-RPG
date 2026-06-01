import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var runtime: RuntimeSessionViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        screen
        .background(Color.black)
        .sheet(isPresented: $runtime.showReportSheet) {
            DiagnosticsReportSheet(runtime: runtime)
        }
        .sheet(isPresented: $runtime.showLastSessionReportSheet) {
            LastSessionReportSheet(runtime: runtime)
        }
        .onAppear {
            runtime.start()
        }
        .onChange(of: scenePhase) { phase in
            runtime.scenePhaseChanged(phase)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            runtime.updateDeviceOrientation()
        }
    }

    @ViewBuilder
    private var screen: some View {
        switch runtime.appScreen {
        case .onboarding:
            CatOnboardingView(runtime: runtime)
        case .hub:
            CatHubView(runtime: runtime)
        case .vsIntro:
            VSScreenView(runtime: runtime)
        case .battle:
            BattleSceneView(runtime: runtime)
        case .reward:
            RewardScreenView(runtime: runtime)
        }
    }
}

struct CatOnboardingView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                profileCard
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Cat name", text: $runtime.catDraftName)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    TextField("Custom title", text: $runtime.catDraftTitle)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                HStack(spacing: 10) {
                    Button {
                        runtime.loadCurrentCameraFrameAsCatPhoto()
                    } label: {
                        Label("CAPTURE CAT", systemImage: "camera.fill")
                            .buttonStyle()
                    }

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("UPLOAD", systemImage: "photo.on.rectangle.angled")
                            .buttonStyle()
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        if runtime.catDraftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            runtime.catDraftName = "SHOIGU"
                        }
                        if runtime.catDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            runtime.catDraftTitle = "DESTROYER"
                        }
                        runtime.lastError = ""
                    } label: {
                        Label("CREATE CAT", systemImage: "pawprint.fill")
                            .buttonStyle()
                    }

                    Button {
                        runtime.saveCatProfile()
                    } label: {
                        Label("SAVE CAT", systemImage: "tray.and.arrow.down.fill")
                            .buttonStyle(accent: .green)
                    }
                    .disabled(runtime.catDraftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || runtime.catDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button {
                        if runtime.catProfile != nil {
                            runtime.startFight()
                        } else {
                            runtime.saveCatProfile()
                            if runtime.catProfile != nil {
                                runtime.startFight()
                            }
                        }
                    } label: {
                        Label("FIGHT", systemImage: "bolt.fill")
                            .buttonStyle(accent: .yellow)
                    }
                    .disabled(runtime.catDraftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || runtime.catDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Text(runtime.lastError.isEmpty ? "Center your cat, move closer, keep the face inside frame, then capture." : runtime.lastError)
                    .font(.caption.monospaced())
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
            }
            .padding(16)
        }
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else { return }
            if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                runtime.catDraftPhoto = image
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("LOOPYCAT")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Create the cat fighter that will take the first boss down.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(.bottom, 4)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                catPhotoPreview
                VStack(alignment: .leading, spacing: 8) {
                    Text(runtime.catDraftName.isEmpty ? "SHOIGU" : runtime.catDraftName.uppercased())
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text(runtime.catDraftTitle.isEmpty ? "DESTROYER" : runtime.catDraftTitle.uppercased())
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color(hex: "#FFD166") ?? .yellow)
                    Text("LEVEL 1")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.white.opacity(0.65))
                    Text("PHOTO / title / local save / battle card")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            .padding(14)
            .background(.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var catPhotoPreview: some View {
        Group {
            if let image = runtime.catDraftPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let image = runtime.currentCatPhoto() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [.purple.opacity(0.75), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 4) {
                        Image(systemName: "cat.fill")
                            .font(.system(size: 30, weight: .bold))
                        Text("NO PHOTO")
                            .font(.caption.monospaced().bold())
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.25), lineWidth: 1))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.yellow.opacity(0.75), style: StrokeStyle(lineWidth: 2, dash: [10, 6]))
                .padding(10)
            Image(systemName: "viewfinder")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(.white.opacity(0.75))
        }
    }
}

struct CatHubView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .indigo.opacity(0.72), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    CatHeroCardView(runtime: runtime, expanded: true)
                    actionArea
                    BossLobbyCard(runtime: runtime)
                    InventorySummaryCard(runtime: runtime)

                    if runtime.debugOverlayEnabled {
                        RuntimeDebugPanelCard(runtime: runtime)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 158)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomControls
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("LOOPYCAT")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text(runtime.debugOverlayEnabled ? "DEBUG MODE" : "FIGHT HUB")
                .font(.caption.monospaced().bold())
                .foregroundStyle(runtime.debugOverlayEnabled ? .green : .yellow)
        }
    }

    private var actionArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MAIN ACTION")
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text(runtime.battleMessage)
                .font(.caption.monospaced().bold())
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var bottomControls: some View {
        VStack(spacing: 10) {
            Button {
                runtime.startFight()
            } label: {
                Label("FIGHT", systemImage: "bolt.fill")
                    .font(.headline.monospaced().bold())
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .foregroundStyle(.black)
                    .background(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                hubButton("Boss Select", systemImage: "crown.fill", color: .white) {
                    runtime.selectNextBossFromHub()
                }
                hubButton("Inventory", systemImage: "shippingbox.fill", color: .white) {
                    runtime.inspectInventoryFromHub()
                }
                hubButton("Diagnostics", systemImage: "doc.text.magnifyingglass", color: .mint) {
                    runtime.requestReport()
                }
                hubButton(runtime.debugOverlayEnabled ? "Debug On" : "Debug Off", systemImage: "ladybug.fill", color: runtime.debugOverlayEnabled ? .green : .gray) {
                    runtime.toggleDebugOverlay()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.black.opacity(0.86))
    }

    private func hubButton(_ title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.monospaced().bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundStyle(.black)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct VSScreenView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [.black, .red.opacity(0.85), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                TimelineView(.periodic(from: Date(), by: 1.0 / 30.0)) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let pulse = 1.0 + sin(time * 3.5) * 0.05
                    let smash = abs(sin(time * 5.0)) * 0.03
                    HStack(spacing: 10) {
                        introCard(
                            title: runtime.catProfile?.name.uppercased() ?? "CAT",
                            subtitle: runtime.catProfile?.title.uppercased() ?? "HERO",
                            image: runtime.currentCatPhoto(),
                            accent: .yellow,
                            side: .leading
                        )
                        VStack(spacing: 18) {
                            Text("VS")
                                .font(.system(size: 56, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: .yellow.opacity(0.85), radius: 16)
                                .scaleEffect(pulse)
                            Text(runtime.battleMessage)
                                .font(.caption.monospaced().bold())
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(width: 110)
                        introCard(
                            title: runtime.selectedBoss.displayName.uppercased(),
                            subtitle: runtime.selectedBoss.subtitle.uppercased(),
                            image: runtime.bossPortraitImage(),
                            accent: Color(hex: runtime.selectedBoss.accentHex) ?? .purple,
                            side: .trailing,
                            bossMode: true
                        )
                    }
                    .padding(.horizontal, 14)
                    .scaleEffect(1.0 + smash)
                }
                .padding(.vertical, 30)

                VStack {
                    Spacer()
                    Text("MATCH STARTING...")
                        .font(.headline.monospaced().bold())
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.bottom, 24)
                }
            }
        }
    }

    private func introCard(title: String, subtitle: String, image: UIImage?, accent: Color, side: HorizontalAlignment, bossMode: Bool = false) -> some View {
        VStack(alignment: side == .leading ? .leading : .trailing, spacing: 12) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 320)
                    .shadow(color: accent.opacity(0.65), radius: 18)
                    .rotationEffect(.degrees(bossMode ? -2 : 2))
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.08))
                    .frame(width: 240, height: 320)
                    .overlay(Image(systemName: "questionmark.square.dashed").font(.largeTitle).foregroundStyle(.white))
            }
            VStack(alignment: side == .leading ? .leading : .trailing, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(accent)
            }
            .frame(maxWidth: 240, alignment: side == .leading ? .leading : .trailing)
        }
        .padding(14)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(accent.opacity(0.35), lineWidth: 1))
    }
}

struct BattleSceneView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        BattleSceneCompositionView(runtime: runtime, includeControls: true, includeDebug: runtime.debugOverlayEnabled)
            .ignoresSafeArea()
    }
}

struct BattleSceneCompositionView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    var includeControls: Bool
    var includeDebug: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                battleBackground

                CameraLayerView(runtime: runtime)

                portalLayer(in: proxy.size)
                bossLayer(in: proxy.size)
                hitMarkerLayer(in: proxy.size)
                floatingDamageLayer(in: proxy.size)
                hudLayer
                if includeControls {
                    controlsLayer
                }
                if runtime.victoryOverlay {
                    victoryLayer
                }
                if runtime.rewardRevealVisible {
                    rewardRevealLayer
                }
            }
            .background(Color.black)
            .overlay(alignment: .center) {
                if runtime.screenFlash {
                    Color.white.opacity(0.22)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
        }
    }

    private var battleBackground: some View {
        LinearGradient(colors: [.black, .brown.opacity(0.55), .purple.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
    }

    private func portalLayer(in size: CGSize) -> some View {
        let anchor = runtime.anchorMemory
        let point = anchor.map { screenPoint(from: CGPoint(x: $0.x, y: $0.y), in: size) } ?? CGPoint(x: size.width * 0.5, y: size.height * 0.56)
        return TimelineView(.periodic(from: Date(), by: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = 1.0 + sin(time * 4.0) * 0.04 + runtime.portalPulse * 0.2
            let ringRotation = Angle.degrees(time * 90.0)
            ZStack {
                ForEach(0..<18, id: \.self) { index in
                    let angle = Double(index) / 18.0 * .pi * 2.0 + time * 1.8
                    let radius = 58.0 + sin(time * 3.0 + Double(index)) * 24.0 + runtime.portalPulse * 44.0
                    Circle()
                        .fill(index.isMultiple(of: 3) ? .yellow.opacity(0.9) : .orange.opacity(0.65))
                        .frame(width: 5 + CGFloat(index % 4), height: 5 + CGFloat(index % 4))
                        .offset(x: cos(angle) * radius, y: sin(angle) * radius * 0.58)
                        .blur(radius: index.isMultiple(of: 4) ? 1.8 : 0)
                }
                Circle()
                    .stroke(.yellow.opacity(0.9), lineWidth: 4)
                    .frame(width: 154 * pulse, height: 154 * pulse)
                Circle()
                    .stroke(.orange.opacity(0.75), style: StrokeStyle(lineWidth: 8, dash: [12, 10]))
                    .frame(width: 198 * pulse, height: 198 * pulse)
                    .rotationEffect(ringRotation)
                Circle()
                    .stroke(.white.opacity(0.42), style: StrokeStyle(lineWidth: 2, dash: [4, 12]))
                    .frame(width: 242 * pulse, height: 118 * pulse)
                    .rotationEffect(.degrees(-time * 70.0))
                Circle()
                    .fill(.yellow.opacity(0.16 + runtime.portalPulse * 0.22))
                    .frame(width: 120 * pulse, height: 120 * pulse)
                    .blur(radius: 10)
                if runtime.portalState == .collapsing || runtime.portalPulse > 0.2 {
                    Image(uiImage: runtime.bossEffectImage(at: time))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260 * pulse, height: 190 * pulse)
                        .blendMode(.screen)
                        .opacity(0.55)
                }
                Text(runtime.battleMessage)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.yellow)
                    .offset(y: -122)
            }
            .position(point)
            .opacity(runtime.portalState == .idle ? 0.0 : 1.0)
        }
    }

    private func bossLayer(in size: CGSize) -> some View {
        let anchor = runtime.anchorMemory
        let point = anchor.map { screenPoint(from: CGPoint(x: $0.x, y: $0.y), in: size) } ?? CGPoint(x: size.width * 0.5, y: size.height * 0.58)
        let bossScale = max(0.72, min(1.45, (anchor?.scale ?? 0.28) * 2.0))
        return TimelineView(.periodic(from: Date(), by: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let sway = sin(time * 2.3 + runtime.bossSwayPhase) * 6.0
            let bob = cos(time * 1.8 + runtime.bossSwayPhase) * 4.0
            let spawnLift = runtime.bossAnimationState == .spawn ? 42.0 - min(42.0, time.truncatingRemainder(dividingBy: 1.2) * 36.0) : 0.0
            let baseScale = bossScale * runtime.bossBreathScale * (runtime.bossAnimationState == .spawn ? 0.70 + min(0.35, runtime.portalPulse * 0.25) : 1.0)
            BossArtworkView(runtime: runtime, time: time)
                .scaleEffect(baseScale)
                .rotationEffect(.degrees(Double(sway) * 0.5))
                .offset(x: runtime.bossLookOffset.x + sway, y: runtime.bossLookOffset.y + bob + spawnLift)
                .shadow(color: Color(hex: runtime.selectedBoss.accentHex)?.opacity(0.9) ?? .purple.opacity(0.7), radius: 24)
                .position(x: point.x, y: point.y - 12)
                .opacity(runtime.anchorActive || runtime.bossAnimationState == .spawn ? 1.0 : 0.25)
        }
    }

    private func hitMarkerLayer(in size: CGSize) -> some View {
        ZStack {
            if runtime.markerFound {
                let rect = markerRect(in: size, normalized: runtime.markerBoundingBox)
                markerReaction(at: CGPoint(x: rect.midX, y: rect.midY), size: max(rect.width, rect.height))
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.yellow.opacity(0.95), lineWidth: 3)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                if includeDebug {
                    Text(runtime.trackingState.rawValue)
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.green)
                        .position(x: rect.midX, y: rect.minY - 12)
                }
            } else if runtime.trackingState == .search || runtime.trackingState == .locking {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.yellow.opacity(0.8), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .frame(width: size.width * 0.4, height: size.height * 0.22)
                    .position(x: size.width * 0.5, y: size.height * 0.5)
                if includeDebug {
                    Text(runtime.battleMessage)
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.yellow)
                        .position(x: size.width * 0.5, y: size.height * 0.5 - 80)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func markerReaction(at point: CGPoint, size: CGFloat) -> some View {
        TimelineView(.periodic(from: Date(), by: 1.0 / 30.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = 1.0 + runtime.portalPulse * 0.6 + abs(sin(time * 8.0)) * 0.08
            ZStack {
                Circle()
                    .stroke(.yellow.opacity(0.75), lineWidth: 3)
                    .frame(width: size * 1.25 * pulse, height: size * 1.25 * pulse)
                Circle()
                    .stroke(.orange.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6, 10]))
                    .frame(width: size * 1.75 * pulse, height: size * 1.75 * pulse)
                    .rotationEffect(.degrees(time * 120))
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(.white.opacity(0.55))
                        .frame(width: 2, height: size * 0.38)
                        .offset(y: -size * 0.48 * pulse)
                        .rotationEffect(.degrees(Double(index) * 36 + time * 80))
                }
            }
            .position(point)
            .offset(x: runtime.cameraShakeIntensity * 8.0, y: runtime.cameraShakeIntensity * -5.0)
        }
    }

    private func floatingDamageLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(runtime.bossFloatTexts) { text in
                let position = screenPoint(from: text.position, in: size)
                Text(text.text)
                    .font(.headline.bold())
                    .foregroundStyle(Color(hex: text.colorHex) ?? .white)
                    .shadow(color: .black.opacity(0.75), radius: 4)
                    .position(position)
                    .offset(y: -CGFloat(Date().timeIntervalSince(text.createdAt) * 26.0))
                    .opacity(1.0 - min(1.0, Date().timeIntervalSince(text.createdAt) / text.lifetime))
            }
        }
        .allowsHitTesting(false)
    }

    private var hudLayer: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("LOOPYCAT RPG AR")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.white)
                    Text(runtime.selectedBoss.displayName.uppercased())
                        .font(.headline.bold())
                        .foregroundStyle(Color(hex: runtime.selectedBoss.accentHex) ?? .white)
                    if includeDebug {
                        Text("TRACKING \(runtime.trackingState.rawValue)  COMBAT \(runtime.combatState.rawValue)")
                            .font(.caption2.monospaced())
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                Spacer()
                if includeDebug {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(runtime.camera.status)
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(.white)
                        Text(runtime.photoStateText)
                            .font(.caption2.monospaced())
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
            .padding(.horizontal, 12)

            HStack(spacing: 12) {
                hpBar
                Text("COMBO x\(runtime.comboCount)")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.yellow)
                Spacer()
                Text(runtime.battleMessage)
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 12)

            Spacer()
        }
        .padding(.top, 10)
        .padding(.bottom, includeControls ? 98 : 48)
        .foregroundStyle(.white)
    }

    private var hpBar: some View {
        let ratio = max(0, min(1, Double(runtime.bossHP) / Double(max(runtime.bossMaxHP, 1))))
        return VStack(alignment: .leading, spacing: 4) {
            Text("HP \(runtime.bossHP)/\(runtime.bossMaxHP)")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.75))
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(.white.opacity(0.18))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(ratio < 0.4 ? .red : .green)
                        .frame(width: proxy.size.width * ratio)
                }
            }
            .frame(width: 180, height: 12)
        }
    }

    private var controlsLayer: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    button(title: "STRIKE", systemImage: "pawprint.fill", color: .orange) {
                        runtime.playerAttack()
                    }
                    button(title: "PHOTO", systemImage: "camera.fill", color: .yellow) {
                        capturePhoto()
                    }
                    button(title: "RESET", systemImage: "arrow.counterclockwise", color: .red) {
                        runtime.resetBattle()
                    }
                    button(title: "REPORT", systemImage: "doc.text.magnifyingglass", color: .mint) {
                        runtime.requestReport()
                    }
                    button(title: "COPY", systemImage: "doc.on.doc.fill", color: .blue) {
                        runtime.copyReportToPasteboard()
                    }
                    if includeDebug {
                        button(title: "DEBUG HIT", systemImage: "burst.fill", color: .orange) {
                            runtime.debugHit()
                        }
                    }
                }
            }
            .padding(10)
            .background(.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
    }

    private var victoryLayer: some View {
        VStack {
            Spacer()
            if let cat = runtime.currentCatPhoto() {
                Image(uiImage: cat)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .yellow.opacity(0.8), radius: 20)
            }
            Text(runtime.battleMessage == "VICTORY" ? "VICTORY" : "FINISH HIM")
                .font(.system(size: runtime.battleMessage == "VICTORY" ? 72 : 54, weight: .black, design: .rounded))
                .foregroundStyle(runtime.battleMessage == "VICTORY" ? .yellow : .white)
                .shadow(color: .red.opacity(0.9), radius: 18)
            Text(runtime.battleMessage)
                .font(.headline.monospaced().bold())
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(runtime.battleMessage == "FINISH HIM" ? 0.62 : 0.35))
    }

    private var rewardRevealLayer: some View {
        VStack {
            Spacer()
            if let currentLoot = runtime.currentLoot {
                RewardCardView(runtime: runtime, loot: currentLoot)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 88)
            }
        }
    }

    private func capturePhoto() {
        runtime.photoCaptureStarted()
        Task { @MainActor in
            let view = BattleSceneCompositionView(runtime: runtime, includeControls: true, includeDebug: runtime.debugOverlayEnabled)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            let renderer = ImageRenderer(content: view)
            renderer.scale = UIScreen.main.scale

            guard let uiImage = renderer.uiImage else {
                runtime.photoCaptureFinished(success: false, message: "IMAGE_RENDERER_EMPTY")
                return
            }

            do {
                try await PhotoLibraryWriter.save(uiImage)
                runtime.photoCaptureFinished(success: true, message: "PHOTO SAVED")
            } catch {
                runtime.photoCaptureFinished(success: false, message: error.localizedDescription)
            }
        }
    }

    private func button(title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                Text(title)
                    .font(.caption.monospaced().bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 10)
            .foregroundStyle(.black)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func screenPoint(from normalized: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: normalized.x * size.width,
            y: (1.0 - normalized.y) * size.height
        )
    }

    private func markerRect(in size: CGSize, normalized: CGRect) -> CGRect {
        CGRect(
            x: normalized.minX * size.width,
            y: (1.0 - normalized.maxY) * size.height,
            width: normalized.width * size.width,
            height: normalized.height * size.height
        )
    }
}

struct CameraLayerView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    @State private var gestureBaseZoom: CGFloat = 1.0
    @State private var zoomGestureActive = false

    var body: some View {
        GeometryReader { proxy in
            if let cameraImage = runtime.currentCameraFrame {
                Image(uiImage: UIImage(cgImage: cameraImage, scale: 1.0, orientation: runtime.orientation.uiImageOrientation))
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .onAppear {
                        gestureBaseZoom = runtime.camera.currentZoomFactor
                    }
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                if !zoomGestureActive {
                                    gestureBaseZoom = runtime.camera.currentZoomFactor
                                    zoomGestureActive = true
                                }
                                runtime.camera.setZoomFactor(gestureBaseZoom * scale)
                            }
                            .onEnded { scale in
                                gestureBaseZoom = max(1.0, gestureBaseZoom * scale)
                                zoomGestureActive = false
                                runtime.camera.setZoomFactor(gestureBaseZoom)
                            }
                    )
                    .onChange(of: runtime.camera.currentZoomFactor) { newZoomFactor in
                        if !zoomGestureActive {
                            gestureBaseZoom = newZoomFactor
                        }
                    }
            } else {
                ZStack {
                    Color.black
                    Text(runtime.debugOverlayEnabled ? runtime.camera.status : "CAMERA STARTING")
                        .font(.headline.monospaced().bold())
                        .foregroundStyle(.white)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .ignoresSafeArea()
    }
}

struct BossArtworkView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    let time: TimeInterval

    var body: some View {
        Group {
            Image(uiImage: runtime.bossAnimationImage(at: time))
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 340, maxHeight: 420)
                .overlay(alignment: .bottom) {
                    Text(runtime.selectedBoss.displayName.uppercased())
                        .font(.caption.monospaced().bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.65))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                        .offset(y: 24)
                }
                .overlay {
                    if runtime.bossAnimationState == .enraged {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.purple.opacity(0.9), lineWidth: 8)
                            .blur(radius: 1.5)
                    }
                    if runtime.bossAnimationState == .death {
                        Image(uiImage: runtime.bossEffectImage(at: time))
                            .resizable()
                            .scaledToFit()
                            .blendMode(.screen)
                            .opacity(0.8)
                    }
                }
        }
    }
}

struct RewardCardView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    let loot: RuntimeLootItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                lootImage
                VStack(alignment: .leading, spacing: 6) {
                    Text(loot.itemName.uppercased())
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(loot.rarity.rawValue)
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(rarityColor)
                    Text(loot.setName.uppercased())
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.8))
                    Text("SLOT \(loot.slot.rawValue)")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
            HStack(spacing: 8) {
                Button {
                    runtime.equipCurrentLoot()
                } label: {
                    Label("EQUIP", systemImage: "checkmark.seal.fill")
                        .buttonStyle(accent: .green)
                }
                Button {
                    runtime.appScreen = .hub
                    runtime.battlePhase = .profileReady
                } label: {
                    Label("HUB", systemImage: "house.fill")
                        .buttonStyle()
                }
                Spacer()
                Button {
                    runtime.startFight()
                } label: {
                    Label("FIGHT NEXT", systemImage: "bolt.fill")
                        .buttonStyle(accent: .yellow)
                }
            }
        }
        .padding(14)
        .background(.black.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(rarityColor.opacity(0.5), lineWidth: 1))
    }

    private var lootImage: some View {
        Group {
            if let image = runtime.lootImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [rarityColor.opacity(0.9), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "gift.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var rarityColor: Color {
        switch loot.rarity {
        case .common: return .white
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        case .mythic: return .red
        }
    }
}

struct CatHeroCardView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel
    var expanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                catImage
                VStack(alignment: .leading, spacing: 6) {
                    Text((runtime.catProfile?.name ?? "NO CAT").uppercased())
                        .font(expanded ? .title.bold() : .headline.bold())
                        .foregroundStyle(.white)
                    Text((runtime.catProfile?.title ?? "CREATE ONE NOW").uppercased())
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.yellow)
                    Text("LEVEL \(runtime.catProfile?.level ?? 1)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }

            equipmentRow
        }
        .padding(14)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private var catImage: some View {
        Group {
            if let image = runtime.currentCatPhoto() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [.orange.opacity(0.8), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "cat.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: expanded ? 112 : 92, height: expanded ? 112 : 92)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var equipmentRow: some View {
        HStack(spacing: 6) {
            ForEach(RuntimeLootSlot.allCases, id: \.self) { slot in
                let itemID = runtime.catProfile?.equippedItems[slot]
                RoundedRectangle(cornerRadius: 8)
                    .fill(itemID == nil ? .white.opacity(0.08) : .green.opacity(0.8))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(slot.rawValue.prefix(1))
                            .font(.caption.monospaced().bold())
                            .foregroundStyle(.white)
                    )
            }
        }
    }
}

struct BossLobbyCard: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BOSS SELECT")
                .font(.headline.bold())
                .foregroundStyle(.white)
            HStack(alignment: .top, spacing: 12) {
                if let boss = runtime.bossImage() {
                    Image(uiImage: boss)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 96, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(runtime.selectedBoss.displayName)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text(runtime.selectedBoss.subtitle)
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.yellow)
                    Text(runtime.selectedBoss.lootSetName.uppercased())
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct InventorySummaryCard: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("INVENTORY")
                .font(.headline.bold())
                .foregroundStyle(.white)
            Text("\(runtime.inventory.count) items saved locally")
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.75))
            HStack(spacing: 8) {
                ForEach(runtime.inventory.suffix(4)) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color(for: item.rarity).opacity(0.9))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "sparkles").foregroundStyle(.black))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func color(for rarity: RuntimeLootRarity) -> Color {
        switch rarity {
        case .common: return .white
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .yellow
        case .mythic: return .red
        }
    }
}

struct RuntimeDebugPanelCard: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("DEBUG", systemImage: "ladybug.fill")
                    .font(.headline.monospaced().bold())
                    .foregroundStyle(.green)
                Spacer()
                Button {
                    runtime.toggleDebugOverlay()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

            RuntimeDebugOverlayView(runtime: runtime)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                debugButton("SHOW DIAGNOSTIC REPORT", systemImage: "doc.text.magnifyingglass", color: .mint) {
                    runtime.requestReport()
                }
                debugButton("COPY DIAGNOSTIC REPORT", systemImage: "doc.on.doc.fill", color: .blue) {
                    runtime.copyReportToPasteboard()
                }
                debugButton("RESET SESSION", systemImage: "arrow.counterclockwise", color: .orange) {
                    runtime.resetBattle()
                }
                debugButton("DEBUG HIT", systemImage: "burst.fill", color: .yellow) {
                    runtime.debugHit()
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.green.opacity(0.32), lineWidth: 1))
    }

    private func debugButton(_ title: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption2.monospaced().bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundStyle(.black)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct RuntimeDebugOverlayView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        let snapshot = runtime.diagnosticSnapshot()
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DEBUG")
                    .font(.caption.monospaced().bold())
                    .foregroundStyle(.yellow)
                debugRow("camera", snapshot.cameraStatus)
                debugRow("camera started", snapshot.cameraStarted ? "YES" : "NO")
                debugRow("zoom", String(format: "%.2fx", runtime.camera.currentZoomFactor))
                debugRow("frame rx", runtime.frameReceived ? "YES" : "NO")
                debugRow("frame count", "\(snapshot.frameCount)")
                debugRow("last frame", snapshot.lastFrameTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")
                debugRow("camera size", "\(snapshot.cameraFrameWidth)x\(snapshot.cameraFrameHeight)")
                debugRow("camera orient", snapshot.cameraFrameOrientation)
                debugRow("detector", "\(snapshot.detectorFrameCount)")
                debugRow("last detect frame", snapshot.lastDetectorFrameTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")
                debugRow("detector size", "\(snapshot.detectorInputWidth)x\(snapshot.detectorInputHeight)")
                debugRow("detector orient", snapshot.detectorInputOrientation)
                debugRow("tracking", snapshot.trackingState)
                debugRow("marker found", runtime.markerFound ? "YES" : "NO")
                debugRow("candidate count", "\(snapshot.markerCandidateCount)")
                debugRow("confidence", String(format: "%.3f", snapshot.lastMarkerConfidence))
                debugRow("last detect", snapshot.lastMarkerTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")
                debugRow("ref loaded", snapshot.referenceMarkerLoaded ? "YES" : "NO")
                debugRow("ref path", snapshot.referenceMarkerPath)
                debugRow("ref print", snapshot.referenceFeaturePrintReady ? "READY" : "NOT READY")
                debugRow("ref error", snapshot.referenceFeaturePrintError)
                debugRow("center", String(format: "(%.3f, %.3f)", runtime.markerCenter.x, runtime.markerCenter.y))
                debugRow("rotation", String(format: "%.3f", runtime.markerRotation))
                debugRow("scale", String(format: "%.3f", runtime.markerScale))
                debugRow("distance", String(format: "%.3f", runtime.markerDistanceEstimate))
                debugRow("bbox", String(format: "(%.3f %.3f %.3f %.3f)", runtime.markerBoundingBox.minX, runtime.markerBoundingBox.minY, runtime.markerBoundingBox.width, runtime.markerBoundingBox.height))
                debugRow("anchor", snapshot.anchorActive ? "YES" : "NO")
                debugRow("last seen", String(format: "%.2fs", snapshot.trackingLastSeenAge))
                debugRow("loss", String(format: "%.2fs", snapshot.lossDuration))
                debugRow("relock cd", String(format: "%.2fs", snapshot.relockCooldownRemaining))
                debugRow("ignore hits", snapshot.hitIgnoreActive ? "YES" : "NO")
                debugRow("boss", "\(snapshot.bossName) / \(snapshot.bossState)")
                debugRow("combat", snapshot.combatState)
                debugRow("hp", "\(snapshot.bossHP)/\(snapshot.bossMaxHP)")
                debugRow("combo", "\(snapshot.comboCount)")
                debugRow("photo", snapshot.photoState)
                debugRow("rec", snapshot.recState)
                debugRow("last fail", runtime.lastFailureReason.isEmpty ? "NONE" : runtime.lastFailureReason)
                Divider().background(.white.opacity(0.5))
                ForEach(snapshot.recentEvents.suffix(25), id: \.id) { event in
                    Text("\(event.timestamp.formatted(date: .omitted, time: .standard)) \(event.name)")
                        .lineLimit(1)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(10)
            .frame(maxWidth: 360, alignment: .leading)
        }
        .frame(maxHeight: 250)
    }

    private func debugRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.68))
                .frame(width: 78, alignment: .leading)
            Text(value)
                .font(.caption2.monospaced().bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

struct DiagnosticsReportSheet: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(runtime.diagnosticReport())
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("Diagnostic Report")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Copy") {
                        runtime.copyReportToPasteboard()
                    }
                    Button("Done") {
                        runtime.showReportSheet = false
                    }
                }
            }
        }
    }
}

struct LastSessionReportSheet: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(runtime.lastSessionReportText)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .navigationTitle("LAST SESSION DIAGNOSTIC REPORT")
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    Button("COPY REPORT") {
                        runtime.copyLastSessionReportToPasteboard()
                    }
                    .reportSheetButton(color: .blue)

                    Button("DISMISS") {
                        runtime.dismissLastSessionReport()
                    }
                    .reportSheetButton(color: .gray)

                    Button("CLEAR OLD REPORT", role: .destructive) {
                        runtime.clearLastSessionReport()
                    }
                    .reportSheetButton(color: .red)
                }
                .padding(12)
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct RewardScreenView: View {
    @ObservedObject var runtime: RuntimeSessionViewModel

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .purple.opacity(0.85), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                Text("VICTORY")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.yellow)
                if let cat = runtime.currentCatPhoto() {
                    Image(uiImage: cat)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 136, height: 136)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.yellow.opacity(0.7), lineWidth: 2))
                }
                VStack(spacing: 4) {
                    Text((runtime.catProfile?.name ?? "LOOPYCAT").uppercased())
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("+120 XP  •  \(runtime.currentLoot?.rarity.rawValue ?? "LOOT") DROP")
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(.white.opacity(0.82))
                }
                if let loot = runtime.currentLoot {
                    RewardCardView(runtime: runtime, loot: loot)
                        .padding(.horizontal, 14)
                } else {
                    Text("No reward generated.")
                        .foregroundStyle(.white)
                }
                HStack(spacing: 10) {
                    Button {
                        runtime.equipCurrentLoot()
                    } label: {
                        Label("EQUIP", systemImage: "checkmark.seal.fill")
                            .buttonStyle(accent: .green)
                    }
                    Button {
                        runtime.appScreen = .hub
                        runtime.battlePhase = .profileReady
                    } label: {
                        Label("HUB", systemImage: "house.fill")
                            .buttonStyle()
                    }
                    Button {
                        runtime.startFight()
                    } label: {
                        Label("FIGHT AGAIN", systemImage: "bolt.fill")
                            .buttonStyle(accent: .yellow)
                    }
                }
            }
            .padding(20)
        }
    }
}

extension View {
    func buttonStyle(accent: Color = .white) -> some View {
        self
            .font(.caption.monospaced().bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .foregroundStyle(.black)
            .background(accent)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func reportSheetButton(color: Color) -> some View {
        self
            .font(.caption.monospaced().bold())
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor)
    }
}
