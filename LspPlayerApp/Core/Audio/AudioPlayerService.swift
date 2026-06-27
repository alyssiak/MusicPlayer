import AVFoundation
import Foundation

protocol AudioPlayerServiceDelegate: AnyObject {
    func audioPlayerServiceDidFinishPlaying(_ service: AudioPlayerServiceProtocol)
}

protocol AudioPlayerServiceProtocol: AnyObject {
    var delegate: AudioPlayerServiceDelegate? { get set }
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var volume: Float { get set }

    func load(track: Track) throws
    func play()
    func pause()
    func stop()
    func seek(to time: TimeInterval)
}

enum AudioPlayerServiceError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Аудиофайл \(fileName).mp3 не найден."
        }
    }
}

final class AudioPlayerService: NSObject, AudioPlayerServiceProtocol {
    weak var delegate: AudioPlayerServiceDelegate?

    private var player: AVAudioPlayer?

    var isPlaying: Bool { player?.isPlaying ?? false }
    var currentTime: TimeInterval { player?.currentTime ?? 0 }
    var duration: TimeInterval { player?.duration ?? 0 }

    var volume: Float {
        get { player?.volume ?? 1 }
        set { player?.volume = newValue }
    }

    func load(track: Track) throws {
        guard let url = Bundle.main.url(
            forResource: track.fileName,
            withExtension: "mp3"
        ) else {
            throw AudioPlayerServiceError.fileNotFound(track.fileName)
        }

        let player = try AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.prepareToPlay()
        self.player = player
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.stop()
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = min(max(0, time), duration)
    }
}

extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        delegate?.audioPlayerServiceDidFinishPlaying(self)
    }
}
