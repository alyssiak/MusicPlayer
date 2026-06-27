import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()

    let trackRepository: TrackRepositoryProtocol
    let audioPlayerService: AudioPlayerServiceProtocol

    private init(
        trackRepository: TrackRepositoryProtocol = LocalTrackRepository(),
        audioPlayerService: AudioPlayerServiceProtocol = AudioPlayerService()
    ) {
        self.trackRepository = trackRepository
        self.audioPlayerService = audioPlayerService
    }
}
