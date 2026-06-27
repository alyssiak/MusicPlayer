import Combine
import SnapKit
import UIKit

final class AlbumViewController: UIViewController {
    private enum Layout {
        static let rowHeight: CGFloat = 76
        static let miniPlayerHeight: CGFloat = 68
        static let miniPlayerSpacing: CGFloat = 8
    }

    private let viewModel: AlbumViewModel
    private let playerViewModel: SongViewModel
    private var cancellables = Set<AnyCancellable>()
    private var isMiniPlayerVisible = false
    private var tableBottomConstraint: Constraint?
    private var tableBottomToMiniPlayerConstraint: Constraint?

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "6"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let blurView = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterialDark)
    )

    private let gradientView = GradientView()
    private let albumHeaderView = AlbumHeaderView()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Layout.rowHeight
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.verticalScrollIndicatorInsets.bottom = 12
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.sectionHeaderHeight = 46
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()

    private let miniPlayerView: MiniPlayerView = {
        let view = MiniPlayerView()
        view.isHidden = true
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 18)
        return view
    }()

    init(
        viewModel: AlbumViewModel,
        playerViewModel: SongViewModel
    ) {
        self.viewModel = viewModel
        self.playerViewModel = playerViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:playerViewModel:)")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureTableView()
        configureMiniPlayer()
        makeConstraints()
        bindPlayer()

        viewModel.loadTracks()
        tableView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderSize()
    }

    private func configureHierarchy() {
        view.backgroundColor = UIColor(
            red: 0.055,
            green: 0.064,
            blue: 0.082,
            alpha: 1
        )
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(gradientView)
        view.addSubview(tableView)
        view.addSubview(miniPlayerView)
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = albumHeaderView
        tableView.register(
            TrackCell.self,
            forCellReuseIdentifier: TrackCell.reuseIdentifier
        )
    }

    private func configureMiniPlayer() {
        miniPlayerView.onPlayPause = { [weak self] in
            self?.playerViewModel.togglePlayback()
        }

        miniPlayerView.onNext = { [weak self] in
            self?.playerViewModel.playNext()
        }

        miniPlayerView.onTap = { [weak self] in
            self?.showPlayer()
        }
    }

    private func makeConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            tableBottomConstraint = make.bottom
                .equalTo(view.safeAreaLayoutGuide)
                .constraint
        }

        miniPlayerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(Layout.miniPlayerHeight)
        }

        tableView.snp.makeConstraints { make in
            tableBottomToMiniPlayerConstraint = make.bottom
                .equalTo(miniPlayerView.snp.top)
                .offset(-Layout.miniPlayerSpacing)
                .constraint
        }
        tableBottomToMiniPlayerConstraint?.deactivate()
    }

    private func updateHeaderSize() {
        let width = tableView.bounds.width
        guard width > 0 else { return }

        let artworkSize = min(280, width - 64)
        let headerHeight = artworkSize + 208
        guard
            albumHeaderView.frame.width != width
                || albumHeaderView.frame.height != headerHeight
        else {
            return
        }

        albumHeaderView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: headerHeight
        )
        tableView.tableHeaderView = albumHeaderView
    }

    private func bindPlayer() {
        playerViewModel.$state
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.renderMiniPlayer(state)
            }
            .store(in: &cancellables)
    }

    private func renderMiniPlayer(_ state: SongPlayerState) {
        miniPlayerView.configure(with: state)
        updatePlayingTrack(state.track)
        guard !isMiniPlayerVisible else { return }

        isMiniPlayerVisible = true
        miniPlayerView.isHidden = false
        tableBottomConstraint?.deactivate()
        tableBottomToMiniPlayerConstraint?.activate()

        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.miniPlayerView.alpha = 1
            self.miniPlayerView.transform = .identity
            self.view.layoutIfNeeded()
        }
    }

    private func updatePlayingTrack(_ track: Track) {
        for case let cell as TrackCell in tableView.visibleCells {
            cell.setPlaying(cell.trackFileName == track.fileName)
        }
    }

    private func showPlayer() {
        guard playerViewModel.state != nil else { return }
        let songViewController = SongViewController(viewModel: playerViewModel)
        songViewController.modalPresentationStyle = .pageSheet
        present(songViewController, animated: true)
    }
}

extension AlbumViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.numberOfTracks
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TrackCell.reuseIdentifier,
                for: indexPath
            ) as? TrackCell,
            let track = viewModel.track(at: indexPath.row)
        else {
            return UITableViewCell()
        }

        cell.configure(
            with: track,
            isPlaying: playerViewModel.state?.track.fileName == track.fileName
        )
        return cell
    }
}

extension AlbumViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        playerViewModel.selectTrack(at: indexPath.row)
    }
}

private final class GradientView: UIView {
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureGradient()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("GradientView is created programmatically")
    }

    private func configureGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else { return }
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.18).cgColor,
            UIColor(
                red: 0.055,
                green: 0.064,
                blue: 0.082,
                alpha: 0.9
            ).cgColor,
            UIColor(
                red: 0.055,
                green: 0.064,
                blue: 0.082,
                alpha: 1
            ).cgColor
        ]
        gradientLayer.locations = [0, 0.48, 1]
    }
}
