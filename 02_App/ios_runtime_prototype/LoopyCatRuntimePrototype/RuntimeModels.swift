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
    case hit = "HIT"
    case phase2 = "PHASE2"
    case enraged = "ENRAGED"
    case defeated = "DEFEATED"
}

enum RuntimeBossAnimationState: String, Codable {
    case spawn = "SPAWN"
    case idle = "IDLE"
    case lookAround = "LOOK_AROUND"
    case taunt = "TAUNT"
    case attackPrep = "ATTACK_PREP"
    case attack = "ATTACK"
    case hitReaction = "HIT_REACTION"
    case comboReaction = "COMBO_REACTION"
    case criticalHit = "CRITICAL_HIT"
    case phase2 = "PHASE_2"
    case enraged = "ENRAGED"
    case victory = "VICTORY"
    case ko = "KO"
    case defeated = "DEFEATED"
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
    var lastMarkerConfidence: Double
    var lastMarkerTimestamp: Date?
    var referenceMarkerLoaded: Bool
    var referenceMarkerPath: String
    var referenceFeaturePrintReady: Bool
    var referenceFeaturePrintError: String
    var trackingState: String
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
    static let bossDefinitions: [RuntimeBossDefinition] = [
        RuntimeBossDefinition(id: "boss01", displayName: "Boss 01", sheetResource: "boss01_raw_sheet", accentHex: "#D95CFF", subtitle: "Prototype Menace", lootSetName: "toy_emperor"),
        RuntimeBossDefinition(id: "boss02", displayName: "Boss 02", sheetResource: "boss02_raw_sheet", accentHex: "#FF8A3D", subtitle: "Prototype Menace", lootSetName: "chaos_hunter"),
        RuntimeBossDefinition(id: "boss03", displayName: "Boss 03", sheetResource: "boss03_raw_sheet", accentHex: "#4CC9F0", subtitle: "Prototype Menace", lootSetName: "spirit_walker"),
        RuntimeBossDefinition(id: "boss04", displayName: "Boss 04", sheetResource: "boss04_raw_sheet", accentHex: "#F9C74F", subtitle: "Prototype Menace", lootSetName: "nature_guardian"),
        RuntimeBossDefinition(id: "boss05", displayName: "Boss 05", sheetResource: "boss05_raw_sheet", accentHex: "#90BE6D", subtitle: "Prototype Menace", lootSetName: "toy_emperor"),
        RuntimeBossDefinition(id: "boss06", displayName: "Boss 06", sheetResource: "boss06_raw_sheet", accentHex: "#F15BB5", subtitle: "Prototype Menace", lootSetName: "chaos_hunter"),
        RuntimeBossDefinition(id: "boss07", displayName: "Spring Clown", sheetResource: "boss07_raw_sheet", accentHex: "#E85D04", subtitle: "Festival Nightmare", lootSetName: "spirit_walker"),
        RuntimeBossDefinition(id: "boss08", displayName: "Boss 08", sheetResource: "boss08_raw_sheet", accentHex: "#2EC4B6", subtitle: "Prototype Menace", lootSetName: "nature_guardian"),
        RuntimeBossDefinition(id: "boss09", displayName: "Boss 09", sheetResource: "boss09_raw_sheet", accentHex: "#8338EC", subtitle: "Prototype Menace", lootSetName: "toy_emperor"),
        RuntimeBossDefinition(id: "boss10", displayName: "Boss 10", sheetResource: "boss10_raw_sheet", accentHex: "#FF006E", subtitle: "Prototype Menace", lootSetName: "chaos_hunter")
    ]

    static let lootDefinitions: [RuntimeLootItem] = [
        RuntimeLootItem(id: "toy_emperor_crown", itemName: "Toy Emperor Crown", rarity: .legendary, setName: "Toy Emperor", slot: .head, sourceBossID: "boss01", imageResource: "toy_emperor_raw_sheet", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "chaos_hunter_aura", itemName: "Chaos Hunter Aura", rarity: .epic, setName: "Chaos Hunter", slot: .aura, sourceBossID: "boss02", imageResource: "chaos_hunter_raw_sheet", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "spirit_walker_tail", itemName: "Spirit Walker Tail", rarity: .rare, setName: "Spirit Walker", slot: .tail, sourceBossID: "boss03", imageResource: "spirit_walker_raw_sheet", obtainedAt: Date(), equipped: false),
        RuntimeLootItem(id: "nature_guardian_neck", itemName: "Nature Guardian Collar", rarity: .common, setName: "Nature Guardian", slot: .neck, sourceBossID: "boss04", imageResource: "nature_guardian_raw_sheet", obtainedAt: Date(), equipped: false)
    ]
}
