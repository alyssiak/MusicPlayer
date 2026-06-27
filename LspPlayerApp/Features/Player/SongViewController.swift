import UIKit

final class SongViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var progressSlider: UISlider!
    @IBOutlet private weak var volumeSlider: UISlider!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!

    var viewModel: SongViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil, "SongViewController requires a SongViewModel")

        configureUI()
        bindViewModel()
        viewModel.setVolume(volumeSlider.value)
        viewModel.load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startPlayback()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopPlayback()
    }

    private func configureUI() {
        imageView.layer.cornerRadius = 22
        imageView.clipsToBounds = true

        playPauseButton.tintColor = .darkGray
        playPauseButton.backgroundColor = .white
        playPauseButton.layer.cornerRadius = 28
        playPauseButton.clipsToBounds = true

        progressSlider.minimumValue = 0
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func render(_ state: SongPlayerState) {
        titleLabel.text = state.track.title
        artistLabel.text = state.track.artist
        imageView.image = UIImage(named: state.track.coverName)

        playPauseButton.setImage(
            UIImage(systemName: state.isPlaying ? "pause.fill" : "play.fill"),
            for: .normal
        )

        progressSlider.maximumValue = Float(state.duration)
        if !progressSlider.isTracking {
            progressSlider.value = Float(state.currentTime)
        }

        currentTimeLabel.text = SongViewModel.formatTime(state.currentTime)
        let remainingTime = max(0, state.duration - state.currentTime)
        durationLabel.text = "-" + SongViewModel.formatTime(remainingTime)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Не удалось включить трек",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction private func progressSliderChanged(_ sender: UISlider) {
        viewModel.seek(to: TimeInterval(sender.value))
    }

    @IBAction private func volumeSliderChanged(_ sender: UISlider) {
        viewModel.setVolume(sender.value)
    }

    @IBAction private func playButton(_ sender: UIButton) {
        viewModel.togglePlayback()
    }

    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        viewModel.playNext()
    }

    @IBAction private func prevButtonPressed(_ sender: UIButton) {
        viewModel.playPrevious()
    }

    @IBAction private func repeatButtonPressed(_ sender: UIButton) {
        sender.tintColor = viewModel.toggleRepeat() ? .systemBlue : .lightGray
    }

    @IBAction private func shuffleButtonPressed(_ sender: UIButton) {
        sender.tintColor = viewModel.toggleShuffle() ? .systemBlue : .lightGray
    }

    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction private func shareButton(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(
            activityItems: [viewModel.shareText()],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
}
