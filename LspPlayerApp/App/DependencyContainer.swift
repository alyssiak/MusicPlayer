import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    let trackRepository: TrackRepositoryProtocol
    let audioPlayerService: AudioPlayerServiceProtocol
    let playbackStateStore: PlaybackStateStoring
    let audioSessionService: AudioSessionConfiguring
    let nowPlayingService: NowPlayingInfoUpdating

    lazy var playerViewModel = SongViewModel(
        tracks: trackRepository.fetchTracks(),
        currentIndex: 0,
        audioPlayerService: audioPlayerService,
        playbackStateStore: playbackStateStore,
        nowPlayingService: nowPlayingService
    )

    private init(
        trackRepository: TrackRepositoryProtocol = LocalTrackRepository(),
        audioPlayerService: AudioPlayerServiceProtocol = AudioPlayerService(),
        playbackStateStore: PlaybackStateStoring = UserDefaultsPlaybackStateStore(),
        audioSessionService: AudioSessionConfiguring = AudioSessionService(),
        nowPlayingService: NowPlayingInfoUpdating = NowPlayingService()
    ) {
        self.trackRepository = trackRepository
        self.audioPlayerService = audioPlayerService
        self.playbackStateStore = playbackStateStore
        self.audioSessionService = audioSessionService
        self.nowPlayingService = nowPlayingService
    }
}
