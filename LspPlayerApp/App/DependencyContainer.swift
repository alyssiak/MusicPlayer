import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    let trackRepository: TrackRepositoryProtocol
    let audioPlayerService: AudioPlayerServiceProtocol

    lazy var playerViewModel = SongViewModel(
        tracks: trackRepository.fetchTracks(),
        currentIndex: 0,
        audioPlayerService: audioPlayerService
    )

    private init(
        trackRepository: TrackRepositoryProtocol = LocalTrackRepository(),
        audioPlayerService: AudioPlayerServiceProtocol = AudioPlayerService()
    ) {
        self.trackRepository = trackRepository
        self.audioPlayerService = audioPlayerService
    }
}
