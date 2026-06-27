import Foundation

final class AlbumViewModel {
    private let repository: TrackRepositoryProtocol

    private(set) var tracks: [Track] = []

    var numberOfTracks: Int {
        tracks.count
    }

    init(repository: TrackRepositoryProtocol) {
        self.repository = repository
    }

    func loadTracks() {
        tracks = repository.fetchTracks()
    }

    func track(at index: Int) -> Track? {
        guard tracks.indices.contains(index) else { return nil }
        return tracks[index]
    }

}
