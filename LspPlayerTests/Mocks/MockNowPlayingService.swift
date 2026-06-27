import Foundation
@testable import LspPlayer

final class MockNowPlayingService: NowPlayingInfoUpdating {
    var updatedTrack: Track?
    var updatedElapsedTime: TimeInterval?
    var updatedDuration: TimeInterval?
    var updatedIsPlaying: Bool?

    var onPlay: (() -> Void)?
    var onPause: (() -> Void)?
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?
    var onSeek: ((TimeInterval) -> Void)?

    func update(
        track: Track,
        elapsedTime: TimeInterval,
        duration: TimeInterval,
        isPlaying: Bool
    ) {
        updatedTrack = track
        updatedElapsedTime = elapsedTime
        updatedDuration = duration
        updatedIsPlaying = isPlaying
    }

    func configureRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onSeek: @escaping (TimeInterval) -> Void
    ) {
        self.onPlay = onPlay
        self.onPause = onPause
        self.onNext = onNext
        self.onPrevious = onPrevious
        self.onSeek = onSeek
    }
}
