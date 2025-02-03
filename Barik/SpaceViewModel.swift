import Combine
import Foundation

/// This view model loads the spaces and their windows.
class SpaceViewModel: ObservableObject {
    @Published var spaces: [SpaceEntity] = []

    init() {
        loadSpaces()
    }

    func loadSpaces() {
        DispatchQueue.global(qos: .background).async {
            if let fetchedSpaces = getSpacesWithWindows() {
                let sortedSpaces = fetchedSpaces.sorted { $0.id < $1.id }
                DispatchQueue.main.async {
                    self.spaces = sortedSpaces
                }
            }
        }
    }
}

// MARK: - Yabai Commands

/// Run a yabai command and return its output data.
private func runYabaiCommand(arguments: [String]) -> Data? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/yabai")
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    do {
        try process.run()
    } catch {
        print("Failed to run yabai: \(error)")
        return nil
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return data
}

/// Get the list of spaces.
private func fetchSpaces() -> [SpaceEntity]? {
    guard let data = runYabaiCommand(arguments: ["-m", "query", "--spaces"]) else {
        return nil
    }
    let decoder = JSONDecoder()
    do {
        let spaces = try decoder.decode([SpaceEntity].self, from: data)
        return spaces
    } catch {
        print("Failed to decode spaces: \(error)")
        return nil
    }
}

/// Get the list of windows.
private func fetchWindows() -> [WindowEntity]? {
    guard let data = runYabaiCommand(arguments: ["-m", "query", "--windows"]) else {
        return nil
    }
    let decoder = JSONDecoder()
    do {
        let windows = try decoder.decode([WindowEntity].self, from: data)
        return windows
    } catch {
        print("Failed to decode windows: \(error)")
        return nil
    }
}

/// Combine spaces and their windows.
private func getSpacesWithWindows() -> [SpaceEntity]? {
    guard let spaces = fetchSpaces(), let windows = fetchWindows() else {
        return nil
    }

    let filteredWindows = windows.filter { !($0.isHidden || $0.isFloating || $0.isSticky) }
    var spaceDict = Dictionary(uniqueKeysWithValues: spaces.map { ($0.id, $0) })

    for window in filteredWindows {
        if var space = spaceDict[window.spaceId] {
            space.windows.append(window)
            spaceDict[window.spaceId] = space
        }
    }

    var resultSpaces = Array(spaceDict.values)
    for index in 0..<resultSpaces.count {
        resultSpaces[index].windows.sort { $0.stackIndex < $1.stackIndex }
    }

    return resultSpaces.filter { !$0.windows.isEmpty }
}
