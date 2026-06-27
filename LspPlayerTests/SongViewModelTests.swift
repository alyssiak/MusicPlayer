import XCTest
@testable import LspPlayer

final class SongViewModelTests: XCTestCase {
    private var audioPlayer: MockAudioPlayerService!
    private var stateStore: MockPlaybackStateStore!
    private var nowPlayingService: MockNowPlayingService!
    private var viewModel: SongViewModel!

    private let tracks = [
        Track(
            title: "Первый трек",
            artist: "ЛСП",
            fileName: "first",
            coverName: "1"
        ),
        Track(
            title: "Второй трек",
            artist: "ЛСП",
            fileName: "second",
            coverName: "2"
        )
    ]

    override func setUp() {
        super.setUp()

        audioPlayer = MockAudioPlayerService()
        stateStore = MockPlaybackStateStore()
        nowPlayingService = MockNowPlayingService()

        viewModel = SongViewModel(
            tracks: tracks,
            currentIndex: 0,
            audioPlayerService: audioPlayer,
            playbackStateStore: stateStore,
            nowPlayingService: nowPlayingService
        )
    }

    override func tearDown() {
        viewModel = nil
        audioPlayer = nil
        stateStore = nil
        nowPlayingService = nil
        super.tearDown()
    }

    func testSelectTrackLoadsTrackAndStartsPlayback() {
        viewModel.selectTrack(at: 1)

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "second")
        XCTAssertTrue(audioPlayer.isPlaying)
        XCTAssertEqual(viewModel.state?.track.fileName, "second")
    }

    func testTogglePlaybackPausesPlayingTrack() {
        viewModel.selectTrack(at: 0)

        viewModel.togglePlayback()

        XCTAssertFalse(audioPlayer.isPlaying)
        XCTAssertEqual(audioPlayer.pauseCallCount, 1)
        XCTAssertEqual(viewModel.state?.isPlaying, false)
    }

    func testPlayNextFromLastTrackReturnsToFirstTrack() {
        viewModel.selectTrack(at: 1)

        viewModel.playNext()

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "first")
        XCTAssertEqual(viewModel.state?.track.fileName, "first")
    }

    func testPlayPreviousFromFirstTrackOpensLastTrack() {
        viewModel.playPreviousTrack()

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "second")
        XCTAssertEqual(viewModel.state?.track.fileName, "second")
    }

    func testSeekChangesTimeAndSavesPosition() {
        viewModel.selectTrack(at: 0)

        viewModel.seek(to: 42)

        XCTAssertEqual(audioPlayer.currentTime, 42)
        XCTAssertEqual(stateStore.savedTrackFileName, "first")
        XCTAssertEqual(stateStore.savedPosition, 42)
    }

    func testInitRestoresLastTrackAndPosition() {
        stateStore.snapshotToLoad = PlaybackSnapshot(
            trackFileName: "second",
            position: 35
        )

        viewModel = SongViewModel(
            tracks: tracks,
            currentIndex: 0,
            audioPlayerService: audioPlayer,
            playbackStateStore: stateStore,
            nowPlayingService: nowPlayingService
        )

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "second")
        XCTAssertEqual(audioPlayer.currentTime, 35)
        XCTAssertEqual(viewModel.state?.track.fileName, "second")
    }

    func testStateChangeUpdatesNowPlayingInfo() {
        viewModel.selectTrack(at: 1)

        XCTAssertEqual(nowPlayingService.updatedTrack?.fileName, "second")
        XCTAssertEqual(nowPlayingService.updatedDuration, 180)
        XCTAssertEqual(nowPlayingService.updatedIsPlaying, true)
    }

    func testRemoteNextCommandOpensNextTrack() {
        nowPlayingService.onNext?()

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "second")
        XCTAssertEqual(viewModel.state?.track.fileName, "second")
    }

    func testFinishedTrackAutomaticallyOpensNextTrack() {
        viewModel.selectTrack(at: 0)

        audioPlayer.delegate?.audioPlayerServiceDidFinishPlaying(audioPlayer)

        XCTAssertEqual(audioPlayer.loadedTrack?.fileName, "second")
        XCTAssertEqual(viewModel.state?.track.fileName, "second")
    }
}
