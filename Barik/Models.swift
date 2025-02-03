import AppKit
import Combine
import Foundation

// MARK: - WindowEntity

struct WindowEntity: Codable, Identifiable, Equatable {
    let id: Int
    let spaceId: Int
    let title: String
    let appName: String?
    let isFocused: Bool
    let stackIndex: Int
    var appIcon: NSImage?
    let isHidden: Bool
    let isFloating: Bool
    let isSticky: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case spaceId = "space"
        case title
        case appName = "app"
        case isFocused = "has-focus"
        case stackIndex = "stack-index"
        case isHidden = "is-hidden"
        case isFloating = "is-floating"
        case isSticky = "is-sticky"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        spaceId = try container.decode(Int.self, forKey: .spaceId)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Unnamed"
        appName = try container.decodeIfPresent(String.self, forKey: .appName)
        isFocused = try container.decode(Bool.self, forKey: .isFocused)
        stackIndex = try container.decodeIfPresent(Int.self, forKey: .stackIndex) ?? 0
        isHidden = try container.decode(Bool.self, forKey: .isHidden)
        isFloating = try container.decode(Bool.self, forKey: .isFloating)
        isSticky = try container.decode(Bool.self, forKey: .isSticky)

        if let appName = appName {
            appIcon = IconCache.shared.icon(for: appName)
        } else {
            appIcon = nil
        }
    }

    static func == (lhs: WindowEntity, rhs: WindowEntity) -> Bool {
        return lhs.id == rhs.id && lhs.spaceId == rhs.spaceId && lhs.title == rhs.title
            && lhs.appName == rhs.appName && lhs.isFocused == rhs.isFocused
            && lhs.stackIndex == rhs.stackIndex && lhs.isHidden == rhs.isHidden
            && lhs.isFloating == rhs.isFloating && lhs.isSticky == rhs.isSticky
    }
}

// MARK: - SpaceEntity

struct SpaceEntity: Codable, Identifiable, Equatable {
    let id: Int
    let isFocused: Bool
    var windows: [WindowEntity] = []

    enum CodingKeys: String, CodingKey {
        case id = "index"
        case isFocused = "has-focus"
    }
}

// MARK: - IconCache

class IconCache {
    static let shared = IconCache()
    private let cache = NSCache<NSString, NSImage>()

    private init() {}

    func icon(for appName: String) -> NSImage? {
        if let cachedIcon = cache.object(forKey: appName as NSString) {
            return cachedIcon
        }

        let workspace = NSWorkspace.shared
        if let app = workspace.runningApplications.first(where: { $0.localizedName == appName }),
            let bundleURL = app.bundleURL
        {
            let icon = workspace.icon(forFile: bundleURL.path)
            cache.setObject(icon, forKey: appName as NSString)
            return icon
        }
        return nil
    }
}
