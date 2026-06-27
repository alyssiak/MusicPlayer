import Foundation

struct PlaybackSnapshot {
    let trackFileName: String
    let position: TimeInterval
    let volume: Float
}

protocol PlaybackStateStoring {
    func load() -> PlaybackSnapshot?
    func save(trackFileName: String, position: TimeInterval, volume: Float)
}

struct UserDefaultsPlaybackStateStore: PlaybackStateStoring {
    private enum Key {
        static let trackFileName = "player.lastTrackFileName"
        static let position = "player.lastPosition"
        static let volume = "player.volume"
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

        let volume = userDefaults.object(forKey: Key.volume) == nil
            ? 0.5
            : userDefaults.float(forKey: Key.volume)

        return PlaybackSnapshot(
            trackFileName: trackFileName,
            position: userDefaults.double(forKey: Key.position),
            volume: volume
        )
    }

    func save(
        trackFileName: String,
        position: TimeInterval,
        volume: Float
    ) {
        userDefaults.set(trackFileName, forKey: Key.trackFileName)
        userDefaults.set(position, forKey: Key.position)
        userDefaults.set(volume, forKey: Key.volume)
    }
}
