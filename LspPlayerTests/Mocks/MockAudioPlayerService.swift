import Foundation
@testable import LspPlayer

final class MockAudioPlayerService: AudioPlayerServiceProtocol {
    weak var delegate: AudioPlayerServiceDelegate?

    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 180

    var loadedTrack: Track?
    var playCallCount = 0
    var pauseCallCount = 0
    var stopCallCount = 0

    func load(track: Track) throws {
        loadedTrack = track
        currentTime = 0
    }

    func play() {
        isPlaying = true
        playCallCount += 1
    }

    func pause() {
        isPlaying = false
        pauseCallCount += 1
    }

    func stop() {
        isPlaying = false
        stopCallCount += 1
    }

    func seek(to time: TimeInterval) {
        currentTime = time
    }
}
