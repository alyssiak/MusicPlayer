import Foundation

struct PlaybackSnapshot {
    let trackFileName: String
    let position: TimeInterval
}

protocol PlaybackStateStoring {
    func load() -> PlaybackSnapshot?
    func save(trackFileName: String, position: TimeInterval)
}

struct UserDefaultsPlaybackStateStore: PlaybackStateStoring {
    private enum Key {
        static let trackFileName = "player.lastTrackFileName"
        static let position = "player.lastPosition"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> PlaybackSnapshot? {
        guard let trackFileName = userDefaults.string(
            forKey: Key.trackFileName
        ) else {
            return nil
        }

        return PlaybackSnapshot(
            trackFileName: trackFileName,
            position: userDefaults.double(forKey: Key.position)
        )
    }

    func save(
        trackFileName: String,
        position: TimeInterval
    ) {
        userDefaults.set(trackFileName, forKey: Key.trackFileName)
        userDefaults.set(position, forKey: Key.position)
    }
}
