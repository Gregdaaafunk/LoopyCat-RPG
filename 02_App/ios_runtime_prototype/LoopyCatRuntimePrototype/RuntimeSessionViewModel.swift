import Foundation
import AVFoundation
import Photos
import SwiftUI
import UIKit

@MainActor
final class RuntimeSessionViewModel: ObservableObject {
    let camera = CameraFrameModel()
    let eventBus = RuntimeEventBus()
    let saveStore = RuntimeSaveStore()
    let orientation = OrientationCoordinator()
    let markerDetector = RuntimeMarkerDetector()

    @Published var appScreen: RuntimeScreen = .onboarding
    @Published var battlePhase: RuntimeBattlePhase = .onboarding
    @Published var trackingState: RuntimeTrackingState = .search
    @Published var combatState: RuntimeCombatState = .idle
    @Published var bossAnimationState: RuntimeBossAnimationState = .idle
    @Published var portalState: RuntimePortalState = .idle
    @Published var recordingState: RuntimeRecordingState = .ready
    @Published var photoStateText = "PHOTO_COMPOSED_UNKNOWN"
    @Published var recStateText = "REC_COMPOSED_UNKNOWN"
    @Published var debugOverlayEnabled = false
    @Published var showReportSheet = false
    @Published var showLastSessionReportSheet = false
    @Published var lastSessionReportText = ""
    @Published var sessionID = UUID().uuidString

    @Published var catProfile: RuntimeCatProfile?
    @Published var catDraftName = ""
    @Published var catDraftTitle = ""
    @Published var catDraftPhoto: UIImage?
    @Published var selectedBoss: RuntimeBossDefinition = RuntimeAssetCatalog.bossDefinitions.first ?? RuntimeBossDefinition(id: "boss01", displayName: "Boss 01", sheetResource: "boss01_raw_sheet", accentHex: "#D95CFF", subtitle: "Prototype Menace", lootSetName: "toy_emperor")
    @Published var currentLoot: RuntimeLootItem?
    @Published var inventory: [RuntimeLootItem] = []
    @Published var settings: RuntimeSettings

    @Published var battleID = UUID().uuidString
    @Published var bossHP = 100
    @Published var bossMaxHP = 100
    @Published var comboCount = 0
    @Published var maxCombo = 0
    @Published var hitsLanded = 0
    @Published var criticalCount = 0
    @Published var damageTotal = 0
    @Published var lastHitKind = "NONE"
    @Published var lastDamage = 0
    @Published var lastError = ""
    @Published var lastFailureReason = ""

    @Published var markerFound = false
    @Published var markerFoundCount = 0
    @Published var markerCandidateCount = 0
    @Published var markerConfidence = 0.0
    @Published var markerCenter = CGPoint.zero
    @Published var markerRotation = 0.0
    @Published var markerScale = 0.0
    @Published var markerBoundingBox = CGRect.zero
    @Published var markerDistanceEstimate = 0.0
    @Published var lastMarkerTimestamp = Date.distantPast
    @Published var trackingLastSeenAge = 0.0
    @Published var lossDuration = 0.0
    @Published var relockCooldownRemaining = 0.0
    @Published var hitIgnoreActive = false
    @Published var anchorActive = false
    @Published var anchorMemory: RuntimeAnchorMemory?

    @Published var cameraPermissionState = "UNKNOWN"
    @Published var photosPermissionState = "UNKNOWN"
    @Published var cameraStarted = false
    @Published var cameraFrameCount = 0
    @Published var cameraFrameSize = CGSize.zero
    @Published var cameraFrameOrientation = "UNKNOWN"
    @Published var detectorInputFrameSize = CGSize.zero
    @Published var detectorInputOrientation = "UNKNOWN"
    @Published var detectorFrameCount = 0
    @Published var lastFrameTimestamp: Date?
    @Published var lastDetectorFrameTimestamp: Date?
    @Published var currentCameraFrame: CGImage?
    @Published var frameReceived = false
    @Published var lastCameraStatus = "IDLE"

    @Published var bossFloatTexts: [RuntimeFloatingText] = []
    @Published var portalPulse = 0.0
    @Published var screenFlash = false
    @Published var cameraShakeIntensity = 0.0
    @Published var bossSwayPhase = 0.0
    @Published var bossBreathScale = 1.0
    @Published var bossLookOffset = CGPoint.zero
    @Published var victoryOverlay = false
    @Published var rewardRevealVisible = false
    @Published var battleMessage = "SEARCHING"

    private var detectionInFlight = false
    private var lastDetectionObservation: RuntimeMarkerObservation?
    private var lastHitDate: Date?
    private var lastComboDate: Date?
    private var lockCandidateStart: Date?
    private var lockCandidateStableCount = 0
    private var lockConfirmedDate: Date?
    private var portalOpenTask: Task<Void, Never>?
    private var victoryTask: Task<Void, Never>?
    private var hitIgnoreUntil: Date?
    private var defeatSequenceUntil: Date?
    private var cameraStartEventSent = false
    private var deviceOrientationTokens: [NSObjectProtocol] = []

    init() {
        settings = saveStore.loadSettings()
        inventory = saveStore.loadInventory()
        catProfile = saveStore.loadCatProfile()
        debugOverlayEnabled = false
        if let previousReport = saveStore.loadLastSessionReport() {
            lastSessionReportText = previousReport
            showLastSessionReportSheet = true
        }
        orientation.forcePortraitLaunch()
        camera.updateOrientation(.portrait)

        if let catProfile {
            catDraftName = catProfile.name
            catDraftTitle = catProfile.title
            catDraftPhoto = saveStore.loadCatPhoto(filename: catProfile.photoFilename)
        }

        camera.frameHandler = { [weak self] image, orientation, size, timestamp in
            Task { @MainActor in
                self?.handleCameraFrame(image, orientation: orientation, size: size, timestamp: timestamp)
            }
        }

        cameraPermissionState = permissionString(for: AVCaptureDevice.authorizationStatus(for: .video))
        photosPermissionState = photoPermissionString(for: PHPhotoLibrary.authorizationStatus(for: .addOnly))

        if catProfile == nil {
            appScreen = .onboarding
            battlePhase = .onboarding
        } else {
            appScreen = .hub
            battlePhase = .profileReady
        }
    }

    func start() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        orientation.forcePortraitLaunch()
        camera.updateOrientation(.portrait)
        cameraStarted = true
        camera.start()
        cameraPermissionState = permissionString(for: AVCaptureDevice.authorizationStatus(for: .video))
        photosPermissionState = photoPermissionString(for: PHPhotoLibrary.authorizationStatus(for: .addOnly))
        camera.lastError = ""
        if cameraPermissionState == "AUTHORIZED" {
            eventBus.emit("camera_permission_granted", owner: "camera_engine", battleID: battleID, payload: [
                "source": "launch_check"
            ])
        }
        eventBus.emit("app_started", owner: "ui_engine", battleID: battleID, payload: [
            "screen": appScreen.rawValue,
            "orientation": orientation.currentOrientation.runtimeString
        ])
        persistDiagnosticReport(reason: "launch")
    }

    func stop() {
        camera.stop()
        cameraStarted = false
        cameraStartEventSent = false
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    func scenePhaseChanged(_ phase: ScenePhase) {
        switch phase {
        case .active:
            eventBus.emit("app_foregrounded", owner: "ui_engine", battleID: battleID, payload: [
                "screen": appScreen.rawValue
            ])
        case .inactive:
            eventBus.emit("app_inactive", owner: "ui_engine", battleID: battleID, payload: [
                "screen": appScreen.rawValue
            ])
            persistDiagnosticReport(reason: "inactive")
        case .background:
            eventBus.emit("app_backgrounded", owner: "ui_engine", battleID: battleID, payload: [
                "screen": appScreen.rawValue
            ])
            persistDiagnosticReport(reason: "background")
        @unknown default:
            persistDiagnosticReport(reason: "unknown_scene_phase")
        }
    }

    func updateDeviceOrientation() {
        let deviceOrientation = UIDevice.current.orientation
        orientation.update(from: deviceOrientation)
        camera.updateOrientation(orientation.currentOrientation)
        eventBus.emit("orientation_changed", owner: "ui_engine", battleID: battleID, payload: [
            "interface": orientation.currentOrientation.runtimeString
        ])
    }

    func toggleDebugOverlay() {
        debugOverlayEnabled.toggle()
        eventBus.emit(debugOverlayEnabled ? "debug_enabled" : "debug_disabled", owner: "ui_engine", battleID: battleID, payload: [:])
        persistDiagnosticReport(reason: "debug_toggle")
    }

    func loadCurrentCameraFrameAsCatPhoto() {
        guard let currentFrame = currentCameraFrame ?? camera.currentFrame else {
            lastError = "No camera frame available to use as cat photo."
            return
        }
        let image = UIImage(cgImage: currentFrame, scale: 1.0, orientation: camera.currentOrientation.uiImageOrientation)
        catDraftPhoto = image
        eventBus.emit("photo_captured", owner: "ui_engine", battleID: battleID, payload: [
            "source": "camera_preview"
        ])
    }

    func saveCatProfile() {
        let trimmedName = catDraftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = catDraftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            lastError = "Cat name is required."
            return
        }
        guard !trimmedTitle.isEmpty else {
            lastError = "Cat title is required."
            return
        }

        var photoFilename: String?
        if let catDraftPhoto, let data = catDraftPhoto.jpegData(compressionQuality: 0.92) {
            let filename = "cat_\(UUID().uuidString).jpg"
            photoFilename = try? saveStore.saveCatPhotoData(data, filename: filename)
        }

        let profile = RuntimeCatProfile(
            id: catProfile?.id ?? UUID().uuidString,
            name: trimmedName,
            title: trimmedTitle,
            photoFilename: photoFilename ?? catProfile?.photoFilename,
            level: catProfile?.level ?? 1,
            xp: catProfile?.xp ?? 0,
            wins: catProfile?.wins ?? 0,
            equippedItems: catProfile?.equippedItems ?? [:],
            updatedAt: Date()
        )

        catProfile = profile
        try? saveStore.saveCatProfile(profile)
        eventBus.emit("cat_updated", owner: "cat_profile_engine", battleID: battleID, payload: [
            "cat_id": profile.id,
            "cat_name": profile.name
        ])
        appScreen = .hub
        battlePhase = .profileReady
        lastError = ""
    }

    func startFight() {
        guard catProfile != nil else {
            lastError = "Create a cat profile first."
            return
        }

        cancelScheduledTasks()
        battleID = UUID().uuidString
        selectBoss()
        resetBattleState()
        appScreen = .vsIntro
        battlePhase = .versus
        battleMessage = "VS"
        eventBus.emit("boss_selected", owner: "boss_engine", battleID: battleID, payload: [
            "boss_id": selectedBoss.id,
            "boss_name": selectedBoss.displayName
        ])
        eventBus.emit("fight_started", owner: "ui_engine", battleID: battleID, payload: [
            "cat_id": catProfile?.id ?? ""
        ])
        eventBus.emit("vs_screen_opened", owner: "ui_engine", battleID: battleID, payload: [
            "boss_id": selectedBoss.id
        ])

        portalOpenTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            await MainActor.run {
                self?.presentBattle()
            }
        }
    }

    func resetBattle() {
        cancelScheduledTasks()
        selectBoss()
        resetBattleState()
        appScreen = catProfile == nil ? .onboarding : .hub
        battlePhase = catProfile == nil ? .onboarding : .profileReady
        battleMessage = "RESET"
        eventBus.emit("battle_reset", owner: "ui_engine", battleID: battleID, payload: [:])
    }

    func selectNextBossFromHub() {
        selectBoss()
        battleMessage = "BOSS READY"
        eventBus.emit("boss_selected", owner: "boss_engine", battleID: battleID, payload: [
            "boss_id": selectedBoss.id,
            "boss_name": selectedBoss.displayName,
            "source": "hub"
        ])
        persistDiagnosticReport(reason: "boss_selected")
    }

    func inspectInventoryFromHub() {
        eventBus.emit("inventory_opened", owner: "ui_engine", battleID: battleID, payload: [
            "item_count": "\(inventory.count)"
        ])
        persistDiagnosticReport(reason: "inventory_opened")
    }

    func debugHit() {
        applyHit(kind: .heavy, source: "DEBUG_HIT", sourceConfidence: 1.0, normalizedLocation: CGPoint(x: 0.5, y: 0.5))
        eventBus.emit("debug_hit_pressed", owner: "ui_engine", battleID: battleID, payload: [:])
    }

    func requestReport() {
        persistDiagnosticReport(reason: "diagnostics_opened")
        showReportSheet = true
    }

    func copyReportToPasteboard() {
        let report = diagnosticReport()
        UIPasteboard.general.string = report
        try? saveStore.saveLastSessionReport(report)
    }

    func copyLastSessionReportToPasteboard() {
        UIPasteboard.general.string = lastSessionReportText
    }

    func dismissLastSessionReport() {
        showLastSessionReportSheet = false
    }

    func clearLastSessionReport() {
        try? saveStore.clearLastSessionReport()
        lastSessionReportText = ""
        showLastSessionReportSheet = false
    }

    func persistDiagnosticReport(reason: String) {
        let report = diagnosticReport(reason: reason)
        try? saveStore.saveLastSessionReport(report)
    }

    func equipCurrentLoot() {
        guard var profile = catProfile, let loot = currentLoot else { return }
        var updatedItems = profile.equippedItems
        updatedItems[loot.slot] = loot.id
        profile.equippedItems = updatedItems
        profile.updatedAt = Date()
        catProfile = profile
        try? saveStore.saveCatProfile(profile)

        currentLoot?.equipped = true

        if let index = inventory.firstIndex(where: { $0.id == loot.id }) {
            inventory[index].equipped = true
            try? saveStore.saveInventory(inventory)
        }

        eventBus.emit("cat_updated", owner: "cat_profile_engine", battleID: battleID, payload: [
            "equipped_slot": loot.slot.rawValue,
            "item_id": loot.id
        ])
    }

    func currentCatPhoto() -> UIImage? {
        if let catDraftPhoto {
            return catDraftPhoto
        }
        if let catProfile {
            return saveStore.loadCatPhoto(filename: catProfile.photoFilename)
        }
        return nil
    }

    func bossImage() -> UIImage? {
        RuntimeMediaLibrary.image(named: selectedBoss.sheetResource)
    }

    func lootImage() -> UIImage? {
        guard let currentLoot else { return nil }
        return RuntimeMediaLibrary.image(named: currentLoot.imageResource ?? "")
    }

    func bossAccentColor() -> UIColor {
        UIColor(hex: selectedBoss.accentHex) ?? .systemPink
    }

    func photoCaptureStarted() {
        recordingState = .capturingPhoto
        photoStateText = "PHOTO_COMPOSED_UNKNOWN"
        eventBus.emit("photo_pressed", owner: "ui_engine", battleID: battleID, payload: [
            "mode": "COMPOSED_OUTPUT"
        ])
        eventBus.emit("recording_started", owner: "recording_engine", battleID: battleID, payload: [
            "mode": "PHOTO",
            "is_composed_output": "true"
        ])
    }

    func photoCaptureFinished(success: Bool, message: String) {
        if success {
            recordingState = .finished
            photoStateText = "PHOTO_COMPOSED_PASS"
            eventBus.emit("photo_saved", owner: "recording_engine", battleID: battleID, payload: [
                "mode": "PHOTO"
            ])
            eventBus.emit("recording_finished", owner: "recording_engine", battleID: battleID, payload: [
                "mode": "PHOTO",
                "saved_to_photos": "true",
                "is_composed_output": "true"
            ])
        } else {
            recordingState = .failed
            photoStateText = "PHOTO_COMPOSED_FAIL"
            lastError = message
            eventBus.emit("photo_failed", owner: "recording_engine", battleID: battleID, payload: [
                "error_message": message
            ], errorFlag: true)
            eventBus.emit("recording_failed", owner: "recording_engine", battleID: battleID, payload: [
                "mode": "PHOTO",
                "error_message": message,
                "is_recoverable": "true"
            ], errorFlag: true)
        }
    }

    func diagnosticSnapshot() -> RuntimeDiagnosticsSnapshot {
        let now = Date()
        let anchor = anchorMemory
        let lastSeenAge = lastMarkerTimestamp == .distantPast ? 9999 : now.timeIntervalSince(lastMarkerTimestamp)
        let anchorAge = anchor == nil ? 9999 : now.timeIntervalSince(anchor?.lastSeenAt ?? now)
        let relockRemaining = hitIgnoreUntil.map { max(0, $0.timeIntervalSince(now)) } ?? 0
        let hitIgnore = hitIgnoreUntil.map { now < $0 } ?? false

        return RuntimeDiagnosticsSnapshot(
            sessionID: sessionID,
            appVersion: RuntimeConstants.appVersion,
            buildVersion: RuntimeConstants.buildVersion,
            deviceModel: UIDevice.current.runtimeModelName,
            systemVersion: UIDevice.current.systemVersion,
            launchOrientation: orientation.launchOrientation.runtimeString,
            currentOrientation: orientation.currentOrientation.runtimeString,
            orientationChanges: orientation.history,
            cameraPermission: cameraPermissionState,
            photosPermission: photosPermissionState,
            cameraStarted: cameraStarted,
            cameraStatus: camera.status,
            frameCount: camera.frameCount,
            lastFrameTimestamp: lastFrameTimestamp,
            cameraFrameWidth: Int(cameraFrameSize.width),
            cameraFrameHeight: Int(cameraFrameSize.height),
            cameraFrameOrientation: cameraFrameOrientation,
            detectorInputWidth: Int(detectorInputFrameSize.width),
            detectorInputHeight: Int(detectorInputFrameSize.height),
            detectorInputOrientation: detectorInputOrientation,
            detectorFrameCount: detectorFrameCount,
            lastDetectorFrameTimestamp: lastDetectorFrameTimestamp,
            markerCandidateCount: markerCandidateCount,
            markerFoundCount: markerFoundCount,
            lastMarkerConfidence: markerConfidence,
            lastMarkerTimestamp: lastMarkerTimestamp == .distantPast ? nil : lastMarkerTimestamp,
            trackingState: trackingState.rawValue,
            trackingLastSeenAge: lastSeenAge,
            anchorActive: anchorActive,
            anchorAge: anchorAge,
            anchorX: anchor?.x ?? 0,
            anchorY: anchor?.y ?? 0,
            anchorRotation: anchor?.rotation ?? 0,
            anchorScale: anchor?.scale ?? 0,
            lossDuration: lossDuration,
            relockCooldownRemaining: relockRemaining,
            hitIgnoreActive: hitIgnore,
            bossID: selectedBoss.id,
            bossName: selectedBoss.displayName,
            bossState: bossAnimationState.rawValue,
            combatState: combatState.rawValue,
            bossHP: bossHP,
            bossMaxHP: bossMaxHP,
            comboCount: comboCount,
            lastHitKind: lastHitKind,
            photoState: photoStateText,
            recState: recStateText,
            lastError: lastError,
            lastFailureReason: lastFailureReason,
            performanceNote: camera.frameCount > 0 ? "FRAME_OK" : "NO_FRAMES",
            recentEvents: Array(eventBus.recentEvents.suffix(50))
        )
    }

    func diagnosticReport(reason: String = "manual") -> String {
        let snapshot = diagnosticSnapshot()
        var lines: [String] = []
        lines.append("LoopyCat Runtime Prototype Diagnostic Report")
        lines.append("report_reason: \(reason)")
        lines.append("report_created_at: \(DateFormatter.runtimeReport.string(from: Date()))")
        lines.append("session_id: \(snapshot.sessionID)")
        lines.append("app_version: \(snapshot.appVersion) (\(snapshot.buildVersion))")
        lines.append("device_model: \(snapshot.deviceModel)")
        lines.append("iOS_version: \(snapshot.systemVersion)")
        lines.append("launch_orientation: \(snapshot.launchOrientation)")
        lines.append("final_orientation: \(snapshot.currentOrientation)")
        lines.append("camera_permission: \(snapshot.cameraPermission)")
        lines.append("photos_permission: \(snapshot.photosPermission)")
        lines.append("camera_started: \(snapshot.cameraStarted)")
        lines.append("camera_status: \(snapshot.cameraStatus)")
        lines.append("frame_count: \(snapshot.frameCount)")
        lines.append("last_frame_time: \(snapshot.lastFrameTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")")
        lines.append("camera_frame_size: \(snapshot.cameraFrameWidth)x\(snapshot.cameraFrameHeight)")
        lines.append("camera_frame_orientation: \(snapshot.cameraFrameOrientation)")
        lines.append("detector_input_size: \(snapshot.detectorInputWidth)x\(snapshot.detectorInputHeight)")
        lines.append("detector_input_orientation: \(snapshot.detectorInputOrientation)")
        lines.append("detector_frame_count: \(snapshot.detectorFrameCount)")
        lines.append("last_detector_frame_time: \(snapshot.lastDetectorFrameTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")")
        lines.append("marker_candidate_count: \(snapshot.markerCandidateCount)")
        lines.append("marker_found_count: \(snapshot.markerFoundCount)")
        lines.append("last_marker_confidence: \(snapshot.lastMarkerConfidence)")
        lines.append("last_marker_timestamp: \(snapshot.lastMarkerTimestamp.map { DateFormatter.runtimeReport.string(from: $0) } ?? "NONE")")
        lines.append("tracking_state: \(snapshot.trackingState)")
        lines.append("tracking_last_seen_age: \(snapshot.trackingLastSeenAge)")
        lines.append("anchor_active: \(snapshot.anchorActive)")
        lines.append("anchor_x: \(snapshot.anchorX)")
        lines.append("anchor_y: \(snapshot.anchorY)")
        lines.append("anchor_rotation: \(snapshot.anchorRotation)")
        lines.append("anchor_scale: \(snapshot.anchorScale)")
        lines.append("loss_duration: \(snapshot.lossDuration)")
        lines.append("relock_cooldown_remaining: \(snapshot.relockCooldownRemaining)")
        lines.append("hit_ignore_active: \(snapshot.hitIgnoreActive)")
        lines.append("boss_id: \(snapshot.bossID)")
        lines.append("boss_name: \(snapshot.bossName)")
        lines.append("boss_state: \(snapshot.bossState)")
        lines.append("combat_state: \(snapshot.combatState)")
        lines.append("boss_hp: \(snapshot.bossHP)/\(snapshot.bossMaxHP)")
        lines.append("combo_count: \(snapshot.comboCount)")
        lines.append("last_hit_kind: \(snapshot.lastHitKind)")
        lines.append("photo_state: \(snapshot.photoState)")
        lines.append("rec_state: \(snapshot.recState)")
        lines.append("last_error: \(snapshot.lastError)")
        lines.append("last_failure_reason: \(snapshot.lastFailureReason)")
        lines.append("performance_note: \(snapshot.performanceNote)")
        lines.append("last_50_important_events:")
        for event in snapshot.recentEvents {
            let payload = event.payload.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", ")
            lines.append("  - \(DateFormatter.runtimeReport.string(from: event.timestamp)) \(event.owner).\(event.name) battle=\(event.battleID) \(payload)")
        }
        return lines.joined(separator: "\n")
    }

    private func presentBattle() {
        appScreen = .battle
        battlePhase = .camera
        trackingState = .search
        battleMessage = "SEARCHING"
        portalState = .searching
        eventBus.emit("camera_opened", owner: "ui_engine", battleID: battleID, payload: [
            "screen": appScreen.rawValue
        ])
        eventBus.emit("detector_started", owner: "tracking_engine", battleID: battleID, payload: [
            "marker": "canonical_marker"
        ])
    }

    private func selectBoss() {
        let candidates = RuntimeAssetCatalog.bossDefinitions.filter { $0.id != selectedBoss.id }
        selectedBoss = candidates.randomElement() ?? RuntimeAssetCatalog.bossDefinitions.randomElement() ?? selectedBoss
        bossMaxHP = 100 + Int.random(in: 0...40)
        bossHP = bossMaxHP
    }

    private func resetBattleState() {
        trackingState = .search
        combatState = .idle
        bossAnimationState = .idle
        portalState = .idle
        recordingState = .ready
        photoStateText = "PHOTO_COMPOSED_UNKNOWN"
        recStateText = "REC_COMPOSED_UNKNOWN"
        markerFound = false
        markerCandidateCount = 0
        markerConfidence = 0
        markerCenter = .zero
        markerRotation = 0
        markerScale = 0
        markerBoundingBox = .zero
        markerDistanceEstimate = 0
        lastMarkerTimestamp = .distantPast
        trackingLastSeenAge = 0
        lossDuration = 0
        relockCooldownRemaining = 0
        hitIgnoreActive = false
        if anchorActive {
            eventBus.emit("anchor_lost", owner: "tracking_engine", battleID: battleID, payload: [
                "source": "battle_reset"
            ])
        }
        anchorActive = false
        anchorMemory = nil
        comboCount = 0
        maxCombo = 0
        hitsLanded = 0
        criticalCount = 0
        damageTotal = 0
        lastHitKind = "NONE"
        lastDamage = 0
        bossFloatTexts.removeAll()
        portalPulse = 0
        screenFlash = false
        cameraShakeIntensity = 0
        bossSwayPhase = 0
        bossBreathScale = 1
        bossLookOffset = .zero
        victoryOverlay = false
        rewardRevealVisible = false
        battleMessage = "SEARCHING"
        currentLoot = nil
        lastError = ""
        lastFailureReason = ""
        defeatSequenceUntil = nil
    }

    private func handleCameraFrame(_ image: CGImage, orientation: CGImagePropertyOrientation, size: CGSize, timestamp: Date) {
        frameReceived = true
        currentCameraFrame = image
        cameraFrameCount = camera.frameCount
        cameraFrameSize = size
        cameraFrameOrientation = orientation.runtimeString
        detectorInputFrameSize = size
        detectorInputOrientation = orientation.runtimeString
        lastFrameTimestamp = timestamp
        lastCameraStatus = camera.status
        cameraPermissionState = camera.permissionState
        detectorFrameCount = markerDetector.processedFrameCount

        if camera.status == "CAMERA_RUNNING" && !cameraStartEventSent {
            cameraStartEventSent = true
            eventBus.emit("camera_started", owner: "camera_engine", battleID: battleID, payload: [
                "frame_size": "\(size.width)x\(size.height)",
                "orientation": orientation.runtimeString
            ])
        }

        guard appScreen == .battle else {
            return
        }
        guard camera.status == "CAMERA_RUNNING" else { return }
        guard !detectionInFlight else { return }
        guard camera.frameCount.isMultiple(of: 2) else { return }

        detectionInFlight = true
        let detector = markerDetector
        DispatchQueue.global(qos: .userInitiated).async { [image, orientation, timestamp] in
            let result = detector.detect(frame: image, orientation: orientation, timestamp: timestamp)
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.detectionInFlight = false
                self.processMarkerDetection(result)
            }
        }
    }

    private func processMarkerDetection(_ result: RuntimeMarkerObservation?) {
        let now = Date()
        detectorFrameCount = markerDetector.processedFrameCount
        lastDetectorFrameTimestamp = now

        if let result {
            markerFound = true
            markerFoundCount += 1
            markerCandidateCount = result.candidateCount
            markerConfidence = result.confidence
            markerCenter = result.center
            markerRotation = result.rotation
            markerScale = result.scale
            markerBoundingBox = result.boundingBox
            markerDistanceEstimate = result.distanceEstimate ?? 0
            lastMarkerTimestamp = result.timestamp
            trackingLastSeenAge = 0
            lossDuration = 0
            lastFailureReason = ""

            if trackingState == .search || trackingState == .lost {
                if anchorActive && lockConfirmedDate != nil {
                    trackingState = .relock
                    battleMessage = "RELOCK"
                    eventBus.emit("relock_started", owner: "tracking_engine", battleID: battleID, payload: [
                        "confidence": String(format: "%.3f", result.confidence)
                    ])
                } else {
                    trackingState = .locking
                    battleMessage = "LOCKING"
                    eventBus.emit("marker_detected", owner: "tracking_engine", battleID: battleID, payload: [
                        "confidence": String(format: "%.3f", result.confidence)
                    ])
                    eventBus.emit("lock_started", owner: "tracking_engine", battleID: battleID, payload: [
                        "confidence": String(format: "%.3f", result.confidence)
                    ])
                }
                lockCandidateStart = result.timestamp
                lockCandidateStableCount = 1
            } else if trackingState == .locking {
                lockCandidateStableCount += 1
            } else if trackingState == .trackingMemory || trackingState == .signalUnstable {
                trackingState = .relock
                battleMessage = "RELOCK"
                eventBus.emit("lock_restored", owner: "tracking_engine", battleID: battleID, payload: [
                    "state": "RELOCK"
                ])
            } else if trackingState == .relock {
                trackingState = .restored
                hitIgnoreUntil = now.addingTimeInterval(0.4)
                battleMessage = "TARGET RESTORED"
            }

            updateAnchor(using: result)
            maybeConfirmLock(using: result)
            maybeRegisterMarkerMotionHit(using: result)
        } else {
            markerFound = false
            markerCandidateCount = markerDetector.lastCandidateCount
            lastFailureReason = markerDetector.lastFailureReason
            trackingLastSeenAge = lastMarkerTimestamp == .distantPast ? 9999 : now.timeIntervalSince(lastMarkerTimestamp)
            lossDuration = trackingLastSeenAge

            if anchorActive {
                if lossDuration < 1.5 {
                    if trackingState != .trackingMemory {
                        trackingState = .trackingMemory
                        battleMessage = "LOCK STABLE"
                        eventBus.emit("lock_lost", owner: "tracking_engine", battleID: battleID, payload: [
                            "loss_duration": String(format: "%.2f", lossDuration)
                        ])
                        eventBus.emit("marker_lost", owner: "tracking_engine", battleID: battleID, payload: [
                            "loss_duration": String(format: "%.2f", lossDuration)
                        ])
                    }
                } else if lossDuration < 5.0 {
                    if trackingState != .signalUnstable {
                        trackingState = .signalUnstable
                        battleMessage = "SIGNAL UNSTABLE"
                    }
                } else {
                    trackingState = .lost
                    battleMessage = "SHOW MARKER AGAIN"
                }
            } else {
                trackingState = .search
            }
        }

        updateMotionEffects()
        updateHitIgnore(now: now)
        updateRelockCooldown(now: now)
        updateFloatingTexts()
    }

    private func updateAnchor(using observation: RuntimeMarkerObservation) {
        let now = observation.timestamp
        guard var anchor = anchorMemory else {
            anchorMemory = RuntimeAnchorMemory(
                x: observation.center.x,
                y: observation.center.y,
                rotation: Double(observation.rotation),
                scale: Double(observation.scale),
                velocityX: 0,
                velocityY: 0,
                lastStableX: observation.center.x,
                lastStableY: observation.center.y,
                lastSeenAt: now,
                confidence: observation.confidence
            )
            eventBus.emit("anchor_created", owner: "tracking_engine", battleID: battleID, payload: [
                "confidence": String(format: "%.3f", observation.confidence)
            ])
            return
        }

        let dt = max(0.016, now.timeIntervalSince(anchor.lastSeenAt))
        let nextX = Double(observation.center.x)
        let nextY = Double(observation.center.y)
        let nextRotation = Double(observation.rotation)
        let nextScale = Double(observation.scale)
        let smoothing = trackingState == .restored || trackingState == .relock ? 0.55 : 0.28

        let velocityX = (nextX - anchor.x) / dt
        let velocityY = (nextY - anchor.y) / dt

        anchor.velocityX = anchor.velocityX * 0.55 + velocityX * 0.45
        anchor.velocityY = anchor.velocityY * 0.55 + velocityY * 0.45
        anchor.x = anchor.x + (nextX - anchor.x) * smoothing
        anchor.y = anchor.y + (nextY - anchor.y) * smoothing
        anchor.rotation = anchor.rotation + (nextRotation - anchor.rotation) * smoothing
        anchor.scale = anchor.scale + (nextScale - anchor.scale) * smoothing
        anchor.lastStableX = anchor.x
        anchor.lastStableY = anchor.y
        anchor.lastSeenAt = now
        anchor.confidence = observation.confidence
        anchorMemory = anchor

        if trackingState == .relock {
            relockCooldownRemaining = 0.4
        }

        if trackingState == .restored {
            trackingState = .locked
        }
    }

    private func maybeConfirmLock(using observation: RuntimeMarkerObservation) {
        guard trackingState == .locking || trackingState == .relock else { return }
        guard let lockCandidateStart else { return }
        let stableDuration = observation.timestamp.timeIntervalSince(lockCandidateStart)
        if stableDuration >= 0.45 || lockCandidateStableCount >= 6 {
            confirmLock(using: observation)
        }
    }

    private func confirmLock(using observation: RuntimeMarkerObservation) {
        let restoringExistingAnchor = anchorActive && lockConfirmedDate != nil
        trackingState = restoringExistingAnchor ? .restored : .locked
        anchorActive = true
        lockConfirmedDate = observation.timestamp
        lockCandidateStart = nil
        lockCandidateStableCount = 0
        hitIgnoreUntil = observation.timestamp.addingTimeInterval(0.4)
        if restoringExistingAnchor {
            battleMessage = "TARGET RESTORED"
            bossAnimationState = .idle
            combatState = .idle
            battlePhase = .active
            eventBus.emit("lock_restored", owner: "tracking_engine", battleID: battleID, payload: [
                "confidence": String(format: "%.3f", observation.confidence)
            ])
        } else {
            battleMessage = "TARGET LOCKED"
            portalState = .opening
            bossAnimationState = .spawn
            combatState = .spawn
            eventBus.emit("lock_confirmed", owner: "tracking_engine", battleID: battleID, payload: [
                "confidence": String(format: "%.3f", observation.confidence)
            ])

            portalOpenTask?.cancel()
            portalOpenTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 650_000_000)
                await MainActor.run {
                    guard let self else { return }
                    self.portalState = .open
                    self.bossAnimationState = .idle
                    self.combatState = .idle
                    self.battlePhase = .active
                    self.eventBus.emit("boss_spawned", owner: "boss_engine", battleID: self.battleID, payload: [
                        "boss_id": self.selectedBoss.id,
                        "boss_name": self.selectedBoss.displayName
                    ])
                }
            }
        }
    }

    private func maybeRegisterMarkerMotionHit(using observation: RuntimeMarkerObservation) {
        guard anchorActive else { return }
        guard trackingState == .locked || trackingState == .restored || trackingState == .trackingMemory else { return }
        guard lastHitDate == nil || Date().timeIntervalSince(lastHitDate ?? .distantPast) > 0.38 else { return }
        guard hitIgnoreUntil.map({ Date() >= $0 }) ?? true else { return }
        guard let lastObservation = lastDetectionObservation else {
            lastDetectionObservation = observation
            return
        }

        let centerDelta = hypot(observation.center.x - lastObservation.center.x, observation.center.y - lastObservation.center.y)
        let scaleDelta = abs(observation.scale - lastObservation.scale)
        let rotationDelta = abs(observation.rotation - lastObservation.rotation)
        let confidenceDrop = lastObservation.confidence - observation.confidence

        let motionScore = centerDelta * 1.5 + scaleDelta * 1.8 + rotationDelta * 0.35 + max(0, confidenceDrop) * 0.8
        let shouldHit = motionScore > 0.14 || confidenceDrop > 0.18

        if shouldHit {
            let kind: RuntimeHitKind
            if motionScore > 0.4 {
                kind = .critical
            } else if motionScore > 0.26 {
                kind = .heavy
            } else if motionScore > 0.18 {
                kind = .normal
            } else {
                kind = .light
            }
            applyHit(kind: kind, source: "MARKER_MOTION", sourceConfidence: observation.confidence, normalizedLocation: observation.center)
        }

        lastDetectionObservation = observation
    }

    private func applyHit(kind: RuntimeHitKind, source: String, sourceConfidence: Double, normalizedLocation: CGPoint) {
        guard hitIgnoreUntil.map({ Date() >= $0 }) ?? true else { return }
        guard combatState != .defeated else { return }

        lastHitDate = Date()
        lastDetectionObservation = nil

        let baseDamage: Int
        switch kind {
        case .light:
            baseDamage = 5
        case .normal:
            baseDamage = 9
        case .heavy:
            baseDamage = 15
        case .critical:
            baseDamage = 24
        }

        let comboWindow: TimeInterval = 1.25
        if let lastComboDate, Date().timeIntervalSince(lastComboDate) <= comboWindow {
            comboCount += 1
        } else {
            comboCount = 1
        }
        maxCombo = max(maxCombo, comboCount)
        lastComboDate = Date()

        hitsLanded += 1
        damageTotal += baseDamage
        lastDamage = baseDamage
        lastHitKind = kind.rawValue
        cameraShakeIntensity = min(1.0, Double(baseDamage) / 24.0)
        screenFlash = true
        portalPulse = 1.0
        bossSwayPhase += 1.3
        bossBreathScale = 1.0 + (Double(baseDamage) * 0.01)
        if kind == .critical {
            bossAnimationState = .criticalHit
        } else if comboCount > 1 {
            bossAnimationState = .comboReaction
        } else {
            bossAnimationState = .hitReaction
        }

        let text = kind.rawValue
        bossFloatTexts.append(RuntimeFloatingText(
            text: "+\(baseDamage) \(text)",
            colorHex: colorHex(for: kind),
            position: normalizedLocation,
            createdAt: Date(),
            lifetime: 1.0
        ))

        if kind == .critical {
            criticalCount += 1
            eventBus.emit("critical_hit", owner: "combat_engine", battleID: battleID, payload: [
                "damage": "\(baseDamage)",
                "source": source
            ])
        }

        eventBus.emit("boss_hit", owner: "combat_engine", battleID: battleID, payload: [
            "damage": "\(baseDamage)",
            "kind": kind.rawValue,
            "source": source,
            "confidence": String(format: "%.3f", sourceConfidence)
        ])
        eventBus.emit("hit_registered", owner: "combat_engine", battleID: battleID, payload: [
            "damage": "\(baseDamage)",
            "kind": kind.rawValue,
            "source": source
        ])

        if comboCount > 1 {
            eventBus.emit("combo_updated", owner: "combat_engine", battleID: battleID, payload: [
                "combo": "\(comboCount)"
            ])
        }

        bossHP = max(0, bossHP - baseDamage)
        if bossHP <= 0 {
            handleBossDefeated()
        } else {
            if bossHP < Int(Double(bossMaxHP) * 0.40) && combatState != .enraged {
                combatState = .enraged
                bossAnimationState = .enraged
                battleMessage = "ENRAGED"
                eventBus.emit("boss_phase_change", owner: "boss_engine", battleID: battleID, payload: [
                    "state": "ENRAGED"
                ])
            } else if bossHP < Int(Double(bossMaxHP) * 0.70) && combatState == .idle {
                combatState = .phase2
                bossAnimationState = .phase2
                battleMessage = "PHASE 2"
                eventBus.emit("boss_phase_change", owner: "boss_engine", battleID: battleID, payload: [
                    "state": "PHASE2"
                ])
            } else if combatState != .enraged {
                combatState = .idle
                bossAnimationState = .idle
            }
        }

        eventBus.emit("screen_pulse", owner: "ui_engine", battleID: battleID, payload: [
            "flash": "true"
        ])
    }

    private func handleBossDefeated() {
        combatState = .defeated
        bossAnimationState = .victory
        battlePhase = .victory
        battleMessage = "FINISHER"
        portalState = .collapsing
        victoryOverlay = true
        rewardRevealVisible = false
        defeatSequenceUntil = Date().addingTimeInterval(0.35)
        eventBus.emit("boss_defeated", owner: "combat_engine", battleID: battleID, payload: [
            "max_combo": "\(maxCombo)",
            "damage_done": "\(damageTotal)"
        ])
        eventBus.emit("ko_sequence_started", owner: "combat_engine", battleID: battleID, payload: [:])
        persistDiagnosticReport(reason: "battle_ended")

        victoryTask?.cancel()
        victoryTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            await MainActor.run {
                guard let self else { return }
                self.bossAnimationState = .ko
                self.battleMessage = "KO"
            }
            try? await Task.sleep(nanoseconds: 550_000_000)
            await MainActor.run {
                guard let self else { return }
                self.spawnLoot()
            }
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                guard let self else { return }
                self.rewardRevealVisible = true
                self.appScreen = .reward
                self.battlePhase = .reward
                self.portalState = .idle
                self.victoryOverlay = false
            }
        }
    }

    private func spawnLoot() {
        let source = RuntimeAssetCatalog.lootDefinitions.randomElement() ?? RuntimeAssetCatalog.lootDefinitions[0]
        let item = RuntimeLootItem(
            id: UUID().uuidString,
            itemName: source.itemName,
            rarity: source.rarity,
            setName: source.setName,
            slot: source.slot,
            sourceBossID: selectedBoss.id,
            imageResource: source.imageResource,
            obtainedAt: Date(),
            equipped: false
        )
        currentLoot = item
        inventory.append(item)
        try? saveStore.saveInventory(inventory)
        try? saveStore.saveReward(item)
        eventBus.emit("loot_dropped", owner: "loot_engine", battleID: battleID, payload: [
            "item_id": item.id,
            "item_name": item.itemName,
            "rarity": item.rarity.rawValue
        ])
        eventBus.emit("loot_reveal_started", owner: "loot_engine", battleID: battleID, payload: [
            "item_id": item.id
        ])
        eventBus.emit("loot_collected", owner: "loot_engine", battleID: battleID, payload: [
            "item_id": item.id
        ])
        eventBus.emit("reward_saved", owner: "save_manager", battleID: battleID, payload: [
            "item_id": item.id
        ])
    }

    private func updateMotionEffects() {
        let now = Date()
        let recentHit = lastHitDate.map { now.timeIntervalSince($0) < 0.35 } ?? false
        if combatState == .idle && !recentHit {
            let cycle = Int(now.timeIntervalSinceReferenceDate * 1.2) % 4
            switch cycle {
            case 0:
                bossAnimationState = .idle
            case 1:
                bossAnimationState = .lookAround
            case 2:
                bossAnimationState = .taunt
            default:
                bossAnimationState = .attackPrep
            }
        } else if combatState == .enraged {
            bossAnimationState = .enraged
        } else if combatState == .defeated {
            if let defeatSequenceUntil, now < defeatSequenceUntil {
                bossAnimationState = .victory
            } else {
                bossAnimationState = .ko
            }
        }

        bossSwayPhase += 0.05 + (cameraShakeIntensity * 0.08)
        let phase = bossSwayPhase
        bossLookOffset = CGPoint(
            x: sin(phase * 1.35) * 4.0 + cameraShakeIntensity * 4.0,
            y: cos(phase * 0.9) * 2.0
        )
        bossBreathScale = 1.0 + sin(phase * 1.5) * 0.015 + cameraShakeIntensity * 0.03
        cameraShakeIntensity *= 0.88
        portalPulse *= 0.92
        screenFlash = screenFlash && cameraShakeIntensity > 0.15
    }

    private func updateFloatingTexts() {
        let now = Date()
        bossFloatTexts = bossFloatTexts.filter { now.timeIntervalSince($0.createdAt) < $0.lifetime }
    }

    private func updateHitIgnore(now: Date) {
        hitIgnoreActive = hitIgnoreUntil.map { now < $0 } ?? false
    }

    private func updateRelockCooldown(now: Date) {
        if let hitIgnoreUntil {
            relockCooldownRemaining = max(0, hitIgnoreUntil.timeIntervalSince(now))
            if relockCooldownRemaining <= 0 {
                trackingState = .locked
            }
        } else {
            relockCooldownRemaining = 0
        }
    }

    private func cancelScheduledTasks() {
        portalOpenTask?.cancel()
        victoryTask?.cancel()
        portalOpenTask = nil
        victoryTask = nil
    }

    private func permissionString(for status: AVAuthorizationStatus) -> String {
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

    private func photoPermissionString(for status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "AUTHORIZED"
        case .limited:
            return "LIMITED"
        case .denied:
            return "DENIED"
        case .notDetermined:
            return "NOT_DETERMINED"
        case .restricted:
            return "RESTRICTED"
        @unknown default:
            return "UNKNOWN"
        }
    }

    private func colorHex(for hitKind: RuntimeHitKind) -> String {
        switch hitKind {
        case .light:
            return "#FFFFFF"
        case .normal:
            return "#FFD166"
        case .heavy:
            return "#FF8A3D"
        case .critical:
            return "#FF3D7F"
        }
    }
}

extension UIDevice {
    var runtimeModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.isEmpty ? model : identifier
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if cleaned.count == 6 {
            cleaned.append("FF")
        }
        guard cleaned.count == 8, let value = UInt64(cleaned, radix: 16) else { return nil }
        let red = CGFloat((value & 0xFF00_0000) >> 24) / 255.0
        let green = CGFloat((value & 0x00FF_0000) >> 16) / 255.0
        let blue = CGFloat((value & 0x0000_FF00) >> 8) / 255.0
        let alpha = CGFloat(value & 0x0000_00FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
