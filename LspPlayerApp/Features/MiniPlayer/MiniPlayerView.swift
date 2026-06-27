import SnapKit
import UIKit

final class MiniPlayerView: UIView {
    var onPlayPause: (() -> Void)?
    var onNext: (() -> Void)?
    var onPrevious: (() -> Void)?
    var onTap: (() -> Void)?
    private var displayedTrackFileName: String?
    private var isSwipeAnimating = false

    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    )

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(
            UIImage(
                systemName: "forward.fill",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18)
            ),
            for: .normal
        )
        return button
    }()

    private let openButton = UIButton(type: .custom)

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .white
        progressView.trackTintColor = .white.withAlphaComponent(0.18)
        return progressView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureActions()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("MiniPlayerView is created programmatically")
    }

    func configure(with state: SongPlayerState) {
        if displayedTrackFileName != state.track.fileName {
            let shouldAnimate = displayedTrackFileName != nil
            displayedTrackFileName = state.track.fileName

            let updates = {
                self.artworkImageView.image = UIImage(named: state.track.coverName)
                self.titleLabel.text = state.track.title
                self.artistLabel.text = state.track.artist
            }

            if shouldAnimate {
                UIView.transition(
                    with: self,
                    duration: 0.25,
                    options: [.transitionCrossDissolve, .beginFromCurrentState],
                    animations: updates
                )
            } else {
                updates()
            }
        }

        let symbolName = state.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(
            UIImage(
                systemName: symbolName,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)
            ),
            for: .normal
        )

        let progress = state.duration > 0
            ? Float(state.currentTime / state.duration)
            : 0
        progressView.setProgress(progress, animated: true)
    }

    private func configureUI() {
        layer.cornerRadius = 18
        layer.masksToBounds = true

        addSubview(blurView)
        addSubview(artworkImageView)
        addSubview(labelsStackView)
        addSubview(playPauseButton)
        addSubview(nextButton)
        addSubview(openButton)
        addSubview(progressView)
    }

    private func configureActions() {
        openButton.addTarget(self, action: #selector(openTapped), for: .touchUpInside)
        playPauseButton.addTarget(
            self,
            action: #selector(playPauseTapped),
            for: .touchUpInside
        )
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let swipeLeft = UISwipeGestureRecognizer(
            target: self,
            action: #selector(playerSwiped)
        )
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(playerSwiped)
        )
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
    }

    private func makeConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        artworkImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview().offset(-1)
            make.size.equalTo(52)
        }

        labelsStackView.snp.makeConstraints { make in
            make.leading.equalTo(artworkImageView.snp.trailing).offset(10)
            make.centerY.equalTo(artworkImageView)
            make.trailing.lessThanOrEqualTo(playPauseButton.snp.leading).offset(-8)
        }

        playPauseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-1)
            make.trailing.equalTo(nextButton.snp.leading).offset(-4)
            make.size.equalTo(44)
        }

        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(playPauseButton)
            make.trailing.equalToSuperview().inset(10)
            make.size.equalTo(44)
        }

        openButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(playPauseButton.snp.leading)
        }

        progressView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func openTapped() {
        onTap?()
    }

    @objc private func playPauseTapped() {
        onPlayPause?()
    }

    @objc private func nextTapped() {
        onNext?()
    }

    @objc private func playerSwiped(_ gesture: UISwipeGestureRecognizer) {
        guard !isSwipeAnimating else { return }
        isSwipeAnimating = true

        let isNext = gesture.direction == .left
        let exitOffset: CGFloat = isNext ? -24 : 24
        let entryOffset = -exitOffset
        let animatedViews = [artworkImageView, labelsStackView]

        UIView.animate(
            withDuration: 0.12,
            animations: {
                animatedViews.forEach {
                    $0.transform = CGAffineTransform(
                        translationX: exitOffset,
                        y: 0
                    )
                    $0.alpha = 0
                }
            },
            completion: { _ in
                if isNext {
                    self.onNext?()
                } else {
                    self.onPrevious?()
                }

                animatedViews.forEach {
                    $0.transform = CGAffineTransform(
                        translationX: entryOffset,
                        y: 0
                    )
                }

                UIView.animate(
                    withDuration: 0.18,
                    delay: 0,
                    options: [.curveEaseOut],
                    animations: {
                        animatedViews.forEach {
                            $0.transform = .identity
                            $0.alpha = 1
                        }
                    },
                    completion: { _ in
                        self.isSwipeAnimating = false
                    }
                )
            }
        )
    }
}
