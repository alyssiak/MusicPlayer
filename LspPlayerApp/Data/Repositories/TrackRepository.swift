import Foundation

protocol TrackRepositoryProtocol {
    func fetchTracks() -> [Track]
}

struct LocalTrackRepository: TrackRepositoryProtocol {
    func fetchTracks() -> [Track] {
        [
            Track(title: "Терминатор", artist: "ЛСП", fileName: "terminator", coverName: "7"),
            Track(title: "Пауза", artist: "ЛСП", fileName: "pause", coverName: "1"),
            Track(title: "Герой", artist: "ЛСП", fileName: "hero", coverName: "2"),
            Track(title: "Шиншиллы", artist: "ЛСП", fileName: "shinshily", coverName: "3"),
            Track(title: "Дворники", artist: "ЛСП", fileName: "dvorniki", coverName: "4"),
            Track(title: "Апатия", artist: "ЛСП", fileName: "apathy", coverName: "5")
        ]
    }
}
