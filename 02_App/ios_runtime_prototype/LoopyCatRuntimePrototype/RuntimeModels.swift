import Foundation
import UIKit

enum RuntimeScreen: String, Codable {
    case onboarding
    case hub
    case vsIntro
    case battle
    case reward
}

enum RuntimeTrackingState: String, Codable {
    case search = "SEARCH"
    case locking = "LOCKING"
    case locked = "LOCKED"
    case trackingMemory = "TRACKING_MEMORY"
    case signalUnstable = "SIGNAL_UNSTABLE"
    case relock = "RELOCK"
    case restored = "RESTORED"
    case lost = "LOST"
}

enum RuntimeCombatState: String, Codable {
    case spawn = "SPAWN"
    case idle = "IDLE"
    case attack = "ATTACK"
    case hit = "HIT"
    case heavyHit = "HEAVY_HIT"
    case knockdown = "KNOCKDOWN"
    case phase2 = "PHASE2"
    case enraged = "ENRAGED"
    case fatality = "FATALITY"
    case defeated = "DEFEATED"
}

enum RuntimeBossAnimationState: String, Codable, CaseIterable {
    case spawn = "SPAWN"
    case idle = "IDLE"
    case taunt = "TAUNT"
    case attack = "ATTACK"
    case hit = "HIT"
    case heavyHit = "HEAVY_HIT"
    case knockdown = "KNOCKDOWN"
    case phase2 = "PHASE_2"
    case enraged = "ENRAGED"
    case victory = "VICTORY"
    case death = "DEATH"
    case loot = "LOOT"
}

enum RuntimeRecordingState: String, Codable {
    case idle = "IDLE"
    case ready = "READY"
    case recording = "RECORDING"
    case capturingPhoto = "CAPTURING_PHOTO"
    case exporting = "EXPORTING"
    case finished = "FINISHED"
    case failed = "FAILED"
}

enum RuntimePortalState: String, Codable {
    case idle = "IDLE"
    case searching = "SEARCHING"
    case opening = "OPENING"
    case open = "OPEN"
    case unstable = "UNSTABLE"
    case collapsing = "COLLAPSING"
}

enum RuntimeBattlePhase: String, Codable {
    case onboarding = "ONBOARDING"
    case profileReady = "PROFILE_READY"
    case versus = "VERSUS"
    case camera = "CAMERA"
    case active = "ACTIVE"
    case victory = "VICTORY"
    case reward = "REWARD"
}

enum RuntimeHitKind: String, Codable, CaseIterable {
    case light = "LIGHT"
    case normal = "NORMAL"
    case heavy = "HEAVY"
    case critical = "CRITICAL"
}

enum RuntimeLootSlot: String, Codable, CaseIterable {
    case head = "HEAD"
    case neck = "NECK"
    case aura = "AURA"
    case tail = "TAIL"
    case special = "SPECIAL"
}

enum RuntimeLootRarity: String, Codable, CaseIterable {
    case common = "COMMON"
    case rare = "RARE"
    case epic = "EPIC"
    case legendary = "LEGENDARY"
    case mythic = "MYTHIC"
}

struct RuntimeCatProfile: Codable, Identifiable {
    var id: String
    var name: String
    var title: String
    var photoFilename: String?
    var level: Int
    var xp: Int
    var wins: Int
    var equippedItems: [RuntimeLootSlot: String]
    var updatedAt: Date

    static func placeholder() -> RuntimeCatProfile {
        RuntimeCatProfile(
            id: UUID().uuidString,
            name: "",
            title: "",
            photoFilename: nil,
            level: 1,
            xp: 0,
            wins: 0,
            equippedItems: [:],
            updatedAt: Date()
        )
    }
}

struct RuntimeBossDefinition: Identifiable, Codable, Hashable {
    var id: String
    var displayName: String
    var sheetResource: String
    var portraitResource: String = ""
    var accentHex: String
    var subtitle: String
    var lootSetName: String
}

struct RuntimeLootItem: Codable, Identifiable, Hashable {
    var id: String
    var itemName: String
    var rarity: RuntimeLootRarity
    var setName: String
    var slot: RuntimeLootSlot
    var sourceBossID: String
    var imageResource: String?
    var obtainedAt: Date
    var equipped: Bool
}

struct RuntimeBattleState: Codable {
    var battleID: String
    var catID: String
    var bossID: String
    var startedAt: Date
    var endedAt: Date?
    var result: String?
    var damageDone: Int
    var hitsLanded: Int
    var maxCombo: Int
    var criticalCount: Int
    var lootIDs: [String]
    var photoID: String?
    var recordingID: String?
}

struct RuntimeAnchorMemory: Codable {
    var x: Double
    var y: Double
    var rotation: Double
    var scale: Double
    var velocityX: Double
    var velocityY: Double
    var lastStableX: Double
    var lastStableY: Double
    var lastSeenAt: Date
    var confidence: Double
}

struct RuntimeMarkerObservation {
    var center: CGPoint
    var boundingBox: CGRect
    var rotation: CGFloat
    var scale: CGFloat
    var confidence: Double
    var distanceEstimate: Double?
    var candidateCount: Int
    var timestamp: Date
    var sourceFrameSize: CGSize
    var sourceOrientation: String
    var failureReason: String?
}

struct RuntimeEvent: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var owner: String
    var battleID: String
    var timestamp: Date
    var payload: [String: String]
    var debugTags: [String]
    var errorFlag: Bool
}

struct RuntimeFloatingText: Identifiable, Hashable {
    var id = UUID().uuidString
    var text: String
    var colorHex: String
    var position: CGPoint
    var createdAt: Date
    var lifetime: TimeInterval
}

struct RuntimeDiagnosticsSnapshot: Codable {
    var sessionID: String
    var appVersion: String
    var buildVersion: String
    var deviceModel: String
    var systemVersion: String
    var launchOrientation: String
    var currentOrientation: String
    var orientationChanges: [String]
    var cameraZoomFactor: Double
    var cameraPermission: String
    var photosPermission: String
    var cameraStarted: Bool
    var cameraStatus: String
    var frameCount: Int
    var lastFrameTimestamp: Date?
    var cameraFrameWidth: Int
    var cameraFrameHeight: Int
    var cameraFrameOrientation: String
    var detectorInputWidth: Int
    var detectorInputHeight: Int
    var detectorInputOrientation: String
    var detectorFrameCount: Int
    var lastDetectorFrameTimestamp: Date?
    var markerCandidateCount: Int
    var markerFoundCount: Int
    var markerCurrentFound: Bool
    var lastMarkerConfidence: Double
    var lastMarkerTimestamp: Date?
    var referenceMarkerLoaded: Bool
    var referenceMarkerPath: String
    var referenceFeaturePrintReady: Bool
    var referenceFeaturePrintError: String
    var trackingState: String
    var trackingLossReason: String
    var trackingLastSeenAge: Double
    var anchorActive: Bool
    var anchorAge: Double
    var anchorX: Double
    var anchorY: Double
    var anchorRotation: Double
    var anchorScale: Double
    var lossDuration: Double
    var relockCooldownRemaining: Double
    var hitIgnoreActive: Bool
    var bossID: String
    var bossName: String
    var bossState: String
    var combatState: String
    var bossHP: Int
    var bossMaxHP: Int
    var comboCount: Int
    var lastHitKind: String
    var photoState: String
    var recState: String
    var lastError: String
    var lastFailureReason: String
    var performanceNote: String
    var recentEvents: [RuntimeEvent]
}

struct RuntimeSettings: Codable {
    var cameraPermissionSeen: Bool
    var photosPermissionSeen: Bool
    var recordingQuality: String
}

enum RuntimeConstants {
    static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
    static let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    static let bundleID = Bundle.main.bundleIdentifier ?? "com.loopycat.runtimeprototype"
}

extension DateFormatter {
    static let runtimeReport: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

extension JSONEncoder {
    static func runtimeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    static func runtimeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

extension RuntimeLootSlot {
    var displayName: String {
        rawValue
    }
}

extension RuntimeLootRarity {
    var displayName: String {
        rawValue
    }
}

extension CGPoint {
    func interpolated(to other: CGPoint, amount: CGFloat) -> CGPoint {
        CGPoint(
            x: x + (other.x - x) * amount,
            y: y + (other.y - y) * amount
        )
    }
}

extension CGSize {
    var cgPoint: CGPoint { CGPoint(x: width, y: height) }
}

extension CGRect {
    var centerPoint: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

enum RuntimeAssetCatalog {
    static let fallbackBossFrame = "full_boss_1"

    static let bossDefinitions: [RuntimeBossDefinition] = [
        RuntimeBossDefinition(id: "djinn01", displayName: "Marker Djinn", sheetResource: "full_boss_1", portraitResource: "Portrait_dead_1", accentHex: "#FFD166", subtitle: "Ancient Artifact Spirit", lootSetName: "arcane_regalia")
    ]

    static let lootDefinitions: [RuntimeLootItem] = [
        RuntimeLootItem(id: "arcane_collar", itemName: "Arcane Collar", rarity: .legendary, setName: "Arcane Regalia", slot: .neck, sourceBossID: "djinn01", imageResource: "Body_armor", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "golden_medal", itemName: "Golden Medal", rarity: .epic, setName: "Arcane Regalia", slot: .special, sourceBossID: "djinn01", imageResource: "Icon", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "spirit_aura", itemName: "Spirit Aura", rarity: .rare, setName: "Arcane Regalia", slot: .aura, sourceBossID: "djinn01", imageResource: "Dissolve_3", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "battle_armor", itemName: "Battle Armor", rarity: .common, setName: "Arcane Regalia", slot: .head, sourceBossID: "djinn01", imageResource: "Head", obtainedAt: Date(), equipped: false)
    ]

    static let idleFrames = ["1", "2", "3", "Loon", "Pertralt"]
    static let spawnFrames = ["spawn4", "Entaaed", "Body_2", "Body_armor", "Head", "Left_arm", "Right_arm", "full_boss_1"]
    static let attackFrames = ["Entaaed", "Loon", "Pertralt", "spawn4"]
    static let hitFrames = ["Hit_1", "Hit_2", "Hit_3", "Hit_4", "Hit_5"]
    static let heavyHitFrames = ["Heavy_Hit_1", "Heavy_Hit_2", "Heavy_Hit_3", "Heavy_Hit_4", "Heavy_Hit_5"]
    static let knockdownFrames = ["Knockdown_1", "Knockdown_2", "Knockdown_3", "Knockdown_4", "Knockdown_5"]
    static let deathFrames = ["Death_1", "Death_2", "Death_3", "Death_4", "Death_5"]
    static let victoryFrames = ["Portrait_dead_1", "Portrait_dead_2", "Portrait_dead_3", "Portrait_dead_4", "Portrait_dead_5"]
    static let dissolveFrames = ["Dissolve_1", "Dissolve_2", "Dissolve_3", "Dissolve_4", "Dissolve_5"]

    static var animationFrameValidationFailures: [String] {
        RuntimeBossAnimationState.allCases.compactMap { state in
            animationFrames(for: state).isEmpty ? state.rawValue : nil
        }
    }

    static func animationFrames(for state: RuntimeBossAnimationState) -> [String] {
        switch state {
        case .spawn:
            return spawnFrames
        case .attack:
            return attackFrames
        case .hit:
            return hitFrames
        case .heavyHit:
            return heavyHitFrames
        case .knockdown:
            return knockdownFrames
        case .phase2, .enraged:
            return heavyHitFrames + idleFrames
        case .death:
            return deathFrames
        case .victory, .loot:
            return victoryFrames
        case .taunt:
            return ["Entaaed", "Pertralt", "Loon"]
        case .idle:
            return idleFrames
        }
    }

    static func frameName(for state: RuntimeBossAnimationState, time: TimeInterval) -> String {
        let frames = animationFrames(for: state)
        guard !frames.isEmpty else {
            return fallbackBossFrame
        }
        let fps = state == .idle ? 3.0 : 8.0
        let index = Int(time * fps) % frames.count
        return frames[index]
    }
}
