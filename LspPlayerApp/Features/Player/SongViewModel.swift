import Combine
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
    @Published private(set) var state: SongPlayerState?
    var onError: ((String) -> Void)?

    private let tracks: [Track]
    private let audioPlayerService: AudioPlayerServiceProtocol
    private let playbackStateStore: PlaybackStateStoring
    private var currentIndex: Int
    private var timer: Timer?
    private var isTrackLoaded = false
    private var isRepeatEnabled = false
    private var isShuffleEnabled = false
    private var lastPersistedPosition: TimeInterval = 0

    var currentTrack: Track {
        tracks[currentIndex]
    }

    var volume: Float {
        audioPlayerService.volume
    }

    init(
        tracks: [Track],
        currentIndex: Int,
        audioPlayerService: AudioPlayerServiceProtocol,
        playbackStateStore: PlaybackStateStoring
    ) {
        precondition(!tracks.isEmpty, "SongViewModel requires at least one track")
        self.tracks = tracks
        self.currentIndex = min(max(0, currentIndex), tracks.count - 1)
        self.audioPlayerService = audioPlayerService
        self.playbackStateStore = playbackStateStore
        self.audioPlayerService.delegate = self
        restorePlaybackState()
    }

    deinit {
        stopTimer()
    }

    func load() {
        guard !isTrackLoaded else {
            notifyStateChanged()
            return
        }
        loadCurrentTrack()
    }

    func startPlayback() {
        if !isTrackLoaded {
            loadCurrentTrack()
        }
        guard isTrackLoaded else { return }
        audioPlayerService.play()
        startTimer()
        notifyStateChanged()
    }

    func stopPlayback() {
        audioPlayerService.stop()
        stopTimer()
        notifyStateChanged()
        writePlaybackState()
    }

    func togglePlayback() {
        if !isTrackLoaded {
            loadCurrentTrack()
        }
        guard isTrackLoaded else { return }

        audioPlayerService.isPlaying
            ? audioPlayerService.pause()
            : audioPlayerService.play()
        if audioPlayerService.isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
        notifyStateChanged()
        writePlaybackState()
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

        playPreviousTrack()
    }

    func playPreviousTrack() {
        currentIndex = currentIndex == 0 ? tracks.count - 1 : currentIndex - 1
        loadAndPlayCurrentTrack()
    }

    func seek(to time: TimeInterval) {
        audioPlayerService.seek(to: time)
        notifyStateChanged()
        writePlaybackState()
    }

    func setVolume(_ volume: Float) {
        audioPlayerService.volume = volume
        writePlaybackState()
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

    func selectTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }

        currentIndex = index
        loadCurrentTrack()
        startPlayback()
        writePlaybackState()
    }

    func savePlaybackState() {
        writePlaybackState()
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
        guard isTrackLoaded else { return }
        audioPlayerService.play()
        startTimer()
        notifyStateChanged()
        writePlaybackState()
    }

    private func loadCurrentTrack() {
        do {
            let volume = audioPlayerService.volume
            try audioPlayerService.load(track: currentTrack)
            audioPlayerService.volume = volume
            isTrackLoaded = true
            notifyStateChanged()
        } catch {
            isTrackLoaded = false
            onError?(error.localizedDescription)
        }
    }

    private func startTimer() {
        stopTimer()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.notifyStateChanged()
            self?.persistPlaybackStateIfNeeded()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func notifyStateChanged() {
        state = SongPlayerState(
            track: currentTrack,
            isPlaying: audioPlayerService.isPlaying,
            currentTime: audioPlayerService.currentTime,
            duration: audioPlayerService.duration,
            isRepeatEnabled: isRepeatEnabled,
            isShuffleEnabled: isShuffleEnabled
        )
    }

    private func restorePlaybackState() {
        guard
            let snapshot = playbackStateStore.load(),
            let restoredIndex = tracks.firstIndex(where: {
                $0.fileName == snapshot.trackFileName
            })
        else {
            return
        }

        currentIndex = restoredIndex
        loadCurrentTrack()
        guard isTrackLoaded else { return }

        audioPlayerService.seek(to: snapshot.position)
        audioPlayerService.volume = snapshot.volume
        lastPersistedPosition = audioPlayerService.currentTime
        notifyStateChanged()
    }

    private func persistPlaybackStateIfNeeded() {
        let currentPosition = audioPlayerService.currentTime
        guard abs(currentPosition - lastPersistedPosition) >= 5 else { return }
        writePlaybackState()
    }

    private func writePlaybackState() {
        guard isTrackLoaded else { return }

        let currentPosition = audioPlayerService.currentTime
        playbackStateStore.save(
            trackFileName: currentTrack.fileName,
            position: currentPosition,
            volume: audioPlayerService.volume
        )
        lastPersistedPosition = currentPosition
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
