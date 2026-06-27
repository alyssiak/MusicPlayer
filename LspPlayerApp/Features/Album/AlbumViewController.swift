import SnapKit
import UIKit

final class AlbumViewController: UIViewController {
    private enum Layout {
        static let horizontalInset: CGFloat = 46
        static let artworkSize: CGFloat = 310
        static let rowHeight: CGFloat = 60
        static let cardHeight: CGFloat = rowHeight * 6 + 8
    }

    private let viewModel: AlbumViewModel
    private let audioPlayerService: AudioPlayerServiceProtocol

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

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "6"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 22
        return imageView
    }()

    private let albumTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Судный день"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "GillSans-SemiBold", size: 32)
            ?? .systemFont(ofSize: 32, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.text = "ЛСП"
        label.textAlignment = .center
        label.textColor = .systemGray5
        label.font = UIFont(name: "GillSans-Italic", size: 25)
            ?? .italicSystemFont(ofSize: 25)
        return label
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 0.09,
            green: 0.096,
            blue: 0.148,
            alpha: 0.25
        )
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Layout.rowHeight
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInset.bottom = 8
        tableView.verticalScrollIndicatorInsets.bottom = 8
        return tableView
    }()

    init(
        viewModel: AlbumViewModel,
        audioPlayerService: AudioPlayerServiceProtocol
    ) {
        self.viewModel = viewModel
        self.audioPlayerService = audioPlayerService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:audioPlayerService:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureTableView()
        makeConstraints()

        viewModel.loadTracks()
        tableView.reloadData()
    }

    private func configureHierarchy() {
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundImageView)
        view.addSubview(blurView)
        view.addSubview(dimView)
        view.addSubview(artworkImageView)
        view.addSubview(albumTitleLabel)
        view.addSubview(artistLabel)
        view.addSubview(cardView)
        cardView.addSubview(tableView)
    }

    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier)
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

        artworkImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(Layout.artworkSize).priority(.high)
            make.width.lessThanOrEqualToSuperview().inset(32)
            make.height.equalTo(artworkImageView.snp.width)
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.38)
        }

        albumTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(albumTitleLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(Layout.cardHeight).priority(.high)
        }

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func showPlayer(for index: Int) {
        guard let songViewModel = viewModel.makeSongViewModel(
            selectedIndex: index,
            audioPlayerService: audioPlayerService
        ) else {
            return
        }

        let songViewController = SongViewController(viewModel: songViewModel)
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

        cell.configure(with: track)
        return cell
    }
}

extension AlbumViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showPlayer(for: indexPath.row)
    }
}
