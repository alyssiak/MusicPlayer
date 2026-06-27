import Foundation

struct SongPlayerState {
    let track: Track
    let isPlaying: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval
    let isRepeatEnabled: Bool
    let isShuffleEnabled: Bool
}

final class SongViewModel {
    var onStateChange: ((SongPlayerState) -> Void)?
    var onError: ((String) -> Void)?

    private let tracks: [Track]
    private let audioPlayerService: AudioPlayerServiceProtocol
    private var currentIndex: Int
    private var timer: Timer?
    private var isRepeatEnabled = false
    private var isShuffleEnabled = false

    var currentTrack: Track {
        tracks[currentIndex]
    }

    init(
        tracks: [Track],
        currentIndex: Int,
        audioPlayerService: AudioPlayerServiceProtocol
    ) {
        precondition(!tracks.isEmpty, "SongViewModel requires at least one track")
        self.tracks = tracks
        self.currentIndex = min(max(0, currentIndex), tracks.count - 1)
        self.audioPlayerService = audioPlayerService
        self.audioPlayerService.delegate = self
    }

    deinit {
        stopTimer()
    }

    func load() {
        loadCurrentTrack()
    }

    func startPlayback() {
        audioPlayerService.play()
        startTimer()
        notifyStateChanged()
    }

    func stopPlayback() {
        audioPlayerService.stop()
        stopTimer()
        notifyStateChanged()
    }

    func togglePlayback() {
        audioPlayerService.isPlaying
            ? audioPlayerService.pause()
            : audioPlayerService.play()
        notifyStateChanged()
    }

    func playNext() {
        if isShuffleEnabled, tracks.count > 1 {
            let availableIndices = tracks.indices.filter { $0 != currentIndex }
            currentIndex = availableIndices.randomElement() ?? currentIndex
        } else {
            currentIndex = (currentIndex + 1) % tracks.count
        }
        loadAndPlayCurrentTrack()
    }

    func playPrevious() {
        if audioPlayerService.currentTime > 3 {
            seek(to: 0)
            return
        }

        currentIndex = currentIndex == 0 ? tracks.count - 1 : currentIndex - 1
        loadAndPlayCurrentTrack()
    }

    func seek(to time: TimeInterval) {
        audioPlayerService.seek(to: time)
        notifyStateChanged()
    }

    func setVolume(_ volume: Float) {
        audioPlayerService.volume = volume
    }

    @discardableResult
    func toggleRepeat() -> Bool {
        isRepeatEnabled.toggle()
        notifyStateChanged()
        return isRepeatEnabled
    }

    @discardableResult
    func toggleShuffle() -> Bool {
        isShuffleEnabled.toggle()
        notifyStateChanged()
        return isShuffleEnabled
    }

    func shareText() -> String {
        "\(currentTrack.title) — \(currentTrack.artist)"
    }

    static func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite else { return "00:00" }
        let totalSeconds = max(0, Int(time))
        return String(
            format: "%02d:%02d",
            totalSeconds / 60,
            totalSeconds % 60
        )
    }

    private func loadAndPlayCurrentTrack() {
        loadCurrentTrack()
        audioPlayerService.play()
        notifyStateChanged()
    }

    private func loadCurrentTrack() {
        do {
            let volume = audioPlayerService.volume
            try audioPlayerService.load(track: currentTrack)
            audioPlayerService.volume = volume
            notifyStateChanged()
        } catch {
            onError?(error.localizedDescription)
        }
    }

    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.notifyStateChanged()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func notifyStateChanged() {
        onStateChange?(
            SongPlayerState(
                track: currentTrack,
                isPlaying: audioPlayerService.isPlaying,
                currentTime: audioPlayerService.currentTime,
                duration: audioPlayerService.duration,
                isRepeatEnabled: isRepeatEnabled,
                isShuffleEnabled: isShuffleEnabled
            )
        )
    }
}

extension SongViewModel: AudioPlayerServiceDelegate {
    func audioPlayerServiceDidFinishPlaying(_ service: AudioPlayerServiceProtocol) {
        if isRepeatEnabled {
            seek(to: 0)
            service.play()
            notifyStateChanged()
        } else {
            playNext()
        }
    }
}
