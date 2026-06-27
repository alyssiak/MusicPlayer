import Combine
import SnapKit
import UIKit

final class SongViewController: UIViewController {
    private let viewModel: SongViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isArtworkTransitioning = false
    private var displayedTrackFileName: String?

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "6"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .light)
    )

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 0.12,
            green: 0.143,
            blue: 0.175,
            alpha: 0.7
        )
        return view
    }()

    private let closeButton = SongViewController.makeTopButton(
        systemName: "chevron.down",
        pointSize: 18
    )

    private let shareButton = SongViewController.makeTopButton(
        systemName: "square.and.arrow.up",
        pointSize: 18
    )

    private let artworkContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.35
        view.layer.shadowRadius = 24
        view.layer.shadowOffset = CGSize(width: 0, height: 14)
        return view
    }()

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.numberOfLines = 1
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.minimumTrackTintColor = UIColor(
            red: 0.45,
            green: 0.72,
            blue: 1,
            alpha: 1
        )
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.25)
        slider.thumbTintColor = .white
        return slider
    }()

    private let currentTimeLabel = SongViewController.makeTimeLabel(
        text: "00:00"
    )
    private let durationLabel = SongViewController.makeTimeLabel(
        text: "00:00"
    )

    private let repeatButton = SongViewController.makeButton(
        systemName: "repeat",
        pointSize: 19,
        tintColor: .lightGray
    )

    private let previousButton = SongViewController.makeButton(
        systemName: "backward.frame",
        pointSize: 25
    )

    private let playPauseButton: UIButton = {
        let button = SongViewController.makeButton(
            systemName: "play.fill",
            pointSize: 24,
            tintColor: .darkGray
        )
        button.backgroundColor = .white
        button.layer.cornerRadius = 28
        return button
    }()

    private let nextButton = SongViewController.makeButton(
        systemName: "forward.frame",
        pointSize: 25
    )

    private let shuffleButton = SongViewController.makeButton(
        systemName: "shuffle",
        pointSize: 19,
        tintColor: .lightGray
    )

    private lazy var controlsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                repeatButton,
                previousButton,
                playPauseButton,
                nextButton,
                shuffleButton
            ]
        )
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let lowVolumeImageView =
        SongViewController.makeImageView(systemName: "speaker.fill")
    private let highVolumeImageView =
        SongViewController.makeImageView(systemName: "speaker.wave.2.fill")

    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        slider.minimumTrackTintColor = .systemRed
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.25)
        return slider
    }()

    private lazy var volumeStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                lowVolumeImageView,
                volumeSlider,
                highVolumeImageView
            ]
        )
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    init(viewModel: SongViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureActions()
        makeConstraints()
        bindViewModel()

        volumeSlider.value = viewModel.volume
    }

    private func configureHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(dimView)
        view.addSubview(closeButton)
        view.addSubview(shareButton)
        view.addSubview(artworkContainerView)
        artworkContainerView.addSubview(artworkImageView)
        view.addSubview(titleLabel)
        view.addSubview(artistLabel)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        view.addSubview(controlsStackView)
        view.addSubview(volumeStackView)
    }

    private func configureActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        progressSlider.addTarget(
            self,
            action: #selector(progressChanged),
            for: .valueChanged
        )
        volumeSlider.addTarget(
            self,
            action: #selector(volumeChanged),
            for: .valueChanged
        )
        repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)

        let swipeLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(artworkSwiped)
        )
        swipeLeft.direction = .left
        artworkContainerView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(artworkSwiped)
        )
        swipeRight.direction = .right
        artworkContainerView.addGestureRecognizer(swipeRight)
    }

    private func makeConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(40)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(40)
        }

        artworkContainerView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(330).priority(.high)
            make.width.lessThanOrEqualToSuperview().inset(24)
            make.height.equalTo(artworkContainerView.snp.width)
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.39)
        }

        artworkImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkContainerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }

        progressSlider.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        currentTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSlider.snp.bottom).offset(2)
            make.leading.equalTo(progressSlider)
        }

        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(currentTimeLabel)
            make.trailing.equalTo(progressSlider)
        }

        controlsStackView.snp.makeConstraints { make in
            make.top.equalTo(currentTimeLabel.snp.bottom).offset(34)
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.lessThanOrEqualTo(volumeStackView.snp.top).offset(-16)
        }

        playPauseButton.snp.makeConstraints { make in
            make.size.equalTo(56)
        }

        [repeatButton, previousButton, nextButton, shuffleButton].forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(44)
            }
        }

        volumeStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(18)
        }

        lowVolumeImageView.snp.makeConstraints { make in
            make.size.equalTo(22)
        }

        highVolumeImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }

    private func bindViewModel() {
        viewModel.$state
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func render(_ state: SongPlayerState) {
        titleLabel.text = state.track.title
        artistLabel.text = state.track.artist
        updateArtwork(for: state.track)

        let playSymbol = state.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(
            UIImage(
                systemName: playSymbol,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)
            ),
            for: .normal
        )

        repeatButton.tintColor = state.isRepeatEnabled ? .systemBlue : .lightGray
        shuffleButton.tintColor = state.isShuffleEnabled ? .systemBlue : .lightGray

        progressSlider.maximumValue = Float(state.duration)
        if !progressSlider.isTracking {
            progressSlider.value = Float(state.currentTime)
        }

        currentTimeLabel.text = SongViewModel.formatTime(state.currentTime)
        let remainingTime = max(0, state.duration - state.currentTime)
        durationLabel.text = SongViewModel.formatTime(remainingTime)
    }

    private func updateArtwork(for track: Track) {
        guard displayedTrackFileName != track.fileName else { return }

        let image = UIImage(named: track.coverName)
        let shouldAnimate = displayedTrackFileName != nil
        displayedTrackFileName = track.fileName

        guard shouldAnimate else {
            artworkImageView.image = image
            backgroundImageView.image = image
            return
        }

        UIView.transition(
            with: artworkImageView,
            duration: 0.25,
            options: [.transitionCrossDissolve, .beginFromCurrentState]
        ) {
            self.artworkImageView.image = image
        }

        UIView.transition(
            with: backgroundImageView,
            duration: 0.5,
            options: [.transitionCrossDissolve, .beginFromCurrentState]
        ) {
            self.backgroundImageView.image = image
        }
    }

    private func showError(_ message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(
            title: "Не удалось включить трек",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func shareTapped() {
        let activityViewController = UIActivityViewController(
            activityItems: [viewModel.shareText()],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }

    @objc private func progressChanged(_ sender: UISlider) {
        viewModel.seek(to: TimeInterval(sender.value))
    }

    @objc private func volumeChanged(_ sender: UISlider) {
        viewModel.setVolume(sender.value)
    }

    @objc private func repeatTapped() {
        viewModel.toggleRepeat()
    }

    @objc private func previousTapped() {
        viewModel.playPrevious()
    }

    @objc private func playPauseTapped() {
        viewModel.togglePlayback()
    }

    @objc private func nextTapped() {
        viewModel.playNext()
    }

    @objc private func shuffleTapped() {
        viewModel.toggleShuffle()
    }

    @objc private func artworkSwiped(_ gesture: UISwipeGestureRecognizer) {
        guard !isArtworkTransitioning else { return }
        isArtworkTransitioning = true

        let isNext = gesture.direction == .left
        let exitOffset: CGFloat = isNext ? -36 : 36
        let entryOffset = -exitOffset

        UIView.animate(
            withDuration: 0.14,
            animations: {
                self.artworkContainerView.transform = CGAffineTransform(
                    translationX: exitOffset,
                    y: 0
                )
                self.artworkContainerView.alpha = 0.25
            },
            completion: { _ in
                if isNext {
                    self.viewModel.playNext()
                } else {
                    self.viewModel.playPreviousTrack()
                }

                self.artworkContainerView.transform = CGAffineTransform(
                    translationX: entryOffset,
                    y: 0
                )

                UIView.animate(
                    withDuration: 0.18,
                    delay: 0,
                    options: [.curveEaseOut]
                ) {
                    self.artworkContainerView.transform = .identity
                    self.artworkContainerView.alpha = 1
                } completion: { _ in
                    self.isArtworkTransitioning = false
                }
            }
        )
    }

    private static func makeButton(
        systemName: String,
        pointSize: CGFloat,
        tintColor: UIColor = .white
    ) -> UIButton {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: pointSize)
        button.setImage(
            UIImage(systemName: systemName, withConfiguration: configuration),
            for: .normal
        )
        button.tintColor = tintColor
        return button
    }

    private static func makeTopButton(
        systemName: String,
        pointSize: CGFloat
    ) -> UIButton {
        let button = makeButton(
            systemName: systemName,
            pointSize: pointSize
        )
        button.backgroundColor = .white.withAlphaComponent(0.09)
        button.layer.cornerRadius = 20
        return button
    }

    private static func makeTimeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        return label
    }

    private static func makeImageView(systemName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(systemName: systemName))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        return imageView
    }
}
