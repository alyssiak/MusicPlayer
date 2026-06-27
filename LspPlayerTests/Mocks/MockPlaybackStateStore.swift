import Foundation
@testable import LspPlayer

final class MockPlaybackStateStore: PlaybackStateStoring {
    var snapshotToLoad: PlaybackSnapshot?
    var savedTrackFileName: String?
    var savedPosition: TimeInterval?

    func load() -> PlaybackSnapshot? {
        snapshotToLoad
    }

    func save(trackFileName: String, position: TimeInterval) {
        savedTrackFileName = trackFileName
        savedPosition = position
    }
}
