import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    let trackRepository: TrackRepositoryProtocol
    let audioPlayerService: AudioPlayerServiceProtocol
    let playbackStateStore: PlaybackStateStoring

    lazy var playerViewModel = SongViewModel(
        tracks: trackRepository.fetchTracks(),
        currentIndex: 0,
        audioPlayerService: audioPlayerService,
        playbackStateStore: playbackStateStore
    )

    private init(
        trackRepository: TrackRepositoryProtocol = LocalTrackRepository(),
        audioPlayerService: AudioPlayerServiceProtocol = AudioPlayerService(),
        playbackStateStore: PlaybackStateStoring = UserDefaultsPlaybackStateStore()
    ) {
        self.trackRepository = trackRepository
        self.audioPlayerService = audioPlayerService
        self.playbackStateStore = playbackStateStore
    }
}
