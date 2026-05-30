import Foundation
import AVFoundation
import UIKit

@MainActor
final class RuntimeEventBus: ObservableObject {
    @Published private(set) var recentEvents: [RuntimeEvent] = []

    func emit(
        _ name: String,
        owner: String,
        battleID: String,
        payload: [String: String] = [:],
        debugTags: [String] = [],
        errorFlag: Bool = false
    ) {
        let event = RuntimeEvent(
            id: UUID().uuidString,
            name: name,
            owner: owner,
            battleID: battleID,
            timestamp: Date(),
            payload: payload,
            debugTags: debugTags,
            errorFlag: errorFlag
        )
        recentEvents.append(event)
        if recentEvents.count > 100 {
            recentEvents.removeFirst(recentEvents.count - 100)
        }
    }

    func reportLines(limit: Int = 100) -> [String] {
        recentEvents.suffix(limit).map { event in
            let payloadSummary = event.payload.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", ")
            let stamp = DateFormatter.runtimeReport.string(from: event.timestamp)
            return "[\(stamp)] \(event.owner).\(event.name) battle=\(event.battleID) \(payloadSummary) \(event.errorFlag ? "ERROR" : "")".trimmingCharacters(in: .whitespaces)
        }
    }
}

final class RuntimeSaveStore {
    private let fileManager = FileManager.default
    private let baseDirectory: URL

    init() {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        baseDirectory = support.appendingPathComponent("LoopyCatRuntimePrototype", isDirectory: true)
        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true, attributes: nil)
        try? fileManager.createDirectory(at: catPhotosDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    var catProfileURL: URL { baseDirectory.appendingPathComponent("cat_profile.json") }
    var inventoryURL: URL { baseDirectory.appendingPathComponent("inventory.json") }
    var settingsURL: URL { baseDirectory.appendingPathComponent("settings.json") }
    var battleHistoryURL: URL { baseDirectory.appendingPathComponent("battle_history.json") }
    var rewardsURL: URL { baseDirectory.appendingPathComponent("rewards.json") }
    var catPhotosDirectory: URL { baseDirectory.appendingPathComponent("cat_photos", isDirectory: true) }

    func loadCatProfile() -> RuntimeCatProfile? {
        loadJSON(RuntimeCatProfile.self, from: catProfileURL)
    }

    func saveCatProfile(_ profile: RuntimeCatProfile) throws {
        try saveJSON(profile, to: catProfileURL)
    }

    func loadInventory() -> [RuntimeLootItem] {
        loadJSON([RuntimeLootItem].self, from: inventoryURL) ?? []
    }

    func saveInventory(_ items: [RuntimeLootItem]) throws {
        try saveJSON(items, to: inventoryURL)
    }

    func loadSettings() -> RuntimeSettings {
        loadJSON(RuntimeSettings.self, from: settingsURL) ?? RuntimeSettings(
            debugOverlayEnabled: true,
            cameraPermissionSeen: false,
            photosPermissionSeen: false,
            recordingQuality: "HIGH"
        )
    }

    func saveSettings(_ settings: RuntimeSettings) throws {
        try saveJSON(settings, to: settingsURL)
    }

    func saveBattleHistory(_ battle: RuntimeBattleState) throws {
        var history = loadBattleHistory()
        history.append(battle)
        if history.count > 100 {
            history.removeFirst(history.count - 100)
        }
        try saveJSON(history, to: battleHistoryURL)
    }

    func loadBattleHistory() -> [RuntimeBattleState] {
        loadJSON([RuntimeBattleState].self, from: battleHistoryURL) ?? []
    }

    func saveReward(_ reward: RuntimeLootItem) throws {
        var rewards = loadRewards()
        rewards.append(reward)
        if rewards.count > 200 {
            rewards.removeFirst(rewards.count - 200)
        }
        try saveJSON(rewards, to: rewardsURL)
    }

    func loadRewards() -> [RuntimeLootItem] {
        loadJSON([RuntimeLootItem].self, from: rewardsURL) ?? []
    }

    func saveCatPhotoData(_ data: Data, filename: String) throws -> String {
        let safeName = filename.replacingOccurrences(of: "/", with: "_")
        let url = catPhotosDirectory.appendingPathComponent(safeName)
        try data.write(to: url, options: [.atomic])
        return url.lastPathComponent
    }

    func loadCatPhoto(filename: String?) -> UIImage? {
        guard let filename else { return nil }
        let url = catPhotosDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    private func loadJSON<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.runtimeDecoder().decode(T.self, from: data)
    }

    private func saveJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try JSONEncoder.runtimeEncoder().encode(value)
        try data.write(to: url, options: [.atomic])
    }
}

enum RuntimeMediaLibrary {
    private static var imageCache: [String: UIImage] = [:]

    static func image(named resourceName: String) -> UIImage? {
        if let cached = imageCache[resourceName] {
            return cached
        }
        guard let bundleURL = Bundle.main.resourceURL else { return nil }
        let enumerator = FileManager.default.enumerator(at: bundleURL, includingPropertiesForKeys: nil)
        while let item = enumerator?.nextObject() as? URL {
            let baseName = item.deletingPathExtension().lastPathComponent
            if baseName == resourceName {
                let image = UIImage(contentsOfFile: item.path)
                if let image {
                    imageCache[resourceName] = image
                }
                return image
            }
        }
        return nil
    }

    static func data(named resourceName: String) -> Data? {
        guard let bundleURL = Bundle.main.resourceURL else { return nil }
        let enumerator = FileManager.default.enumerator(at: bundleURL, includingPropertiesForKeys: nil)
        while let item = enumerator?.nextObject() as? URL {
            let baseName = item.deletingPathExtension().lastPathComponent
            if baseName == resourceName {
                return try? Data(contentsOf: item)
            }
        }
        return nil
    }
}

@MainActor
final class OrientationCoordinator: ObservableObject {
    @Published private(set) var currentOrientation: UIInterfaceOrientation = .portrait
    @Published private(set) var launchOrientation: UIInterfaceOrientation = .portrait
    @Published private(set) var history: [String] = []

    func forcePortraitLaunch() {
        launchOrientation = .portrait
        currentOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        record("portrait_launch")
    }

    func update(from deviceOrientation: UIDeviceOrientation) {
        let mapped = Self.interfaceOrientation(from: deviceOrientation)
        guard mapped != currentOrientation else { return }
        currentOrientation = mapped
        record("orientation_changed \(mapped.runtimeString)")
    }

    var imageOrientation: CGImagePropertyOrientation {
        switch currentOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        default:
            return .right
        }
    }

    var videoOrientation: AVCaptureVideoOrientation {
        switch currentOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }

    private func record(_ entry: String) {
        history.append("\(DateFormatter.runtimeReport.string(from: Date())) \(entry)")
        if history.count > 20 {
            history.removeFirst(history.count - 20)
        }
    }

    static func interfaceOrientation(from deviceOrientation: UIDeviceOrientation) -> UIInterfaceOrientation {
        switch deviceOrientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
}

extension UIInterfaceOrientation {
    var runtimeString: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        default:
            return "unknown"
        }
    }
}

extension AVCaptureVideoOrientation {
    var runtimeString: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        @unknown default:
            return "unknown"
        }
    }
}

extension CGImagePropertyOrientation {
    var runtimeString: String {
        switch self {
        case .up:
            return "up"
        case .upMirrored:
            return "upMirrored"
        case .down:
            return "down"
        case .downMirrored:
            return "downMirrored"
        case .leftMirrored:
            return "leftMirrored"
        case .rightMirrored:
            return "rightMirrored"
        case .left:
            return "left"
        case .right:
            return "right"
        @unknown default:
            return "unknown"
        }
    }
}
