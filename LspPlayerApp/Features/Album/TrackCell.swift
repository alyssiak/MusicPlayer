import SnapKit
import UIKit

final class TrackCell: UITableViewCell {
    static let reuseIdentifier = "TrackCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.055)
        view.layer.cornerRadius = 14
        return view
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 9
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.58)
        label.font = .systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let playingImageView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: 15,
            weight: .semibold
        )
        let imageView = UIImageView(
            image: UIImage(
                systemName: "waveform",
                withConfiguration: configuration
            )
        )
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private(set) var trackFileName: String?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("TrackCell is created programmatically")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackFileName = nil
        coverImageView.image = nil
        titleLabel.text = nil
        artistLabel.text = nil
        setPlaying(false)
    }

    func configure(with track: Track, isPlaying: Bool) {
        trackFileName = track.fileName
        coverImageView.image = UIImage(named: track.coverName)
        titleLabel.text = track.title
        artistLabel.text = track.artist
        setPlaying(isPlaying)
    }

    func setPlaying(_ isPlaying: Bool) {
        playingImageView.isHidden = !isPlaying
        titleLabel.textColor = isPlaying ? .systemGreen : .white
        containerView.backgroundColor = isPlaying
            ? UIColor.systemGreen.withAlphaComponent(0.1)
            : UIColor.white.withAlphaComponent(0.055)
    }

    private func configureUI() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(coverImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(artistLabel)
        containerView.addSubview(playingImageView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        coverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.size.equalTo(52)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(playingImageView.snp.leading).offset(-10)
            make.bottom.equalTo(containerView.snp.centerY).offset(-2)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.centerY).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(playingImageView.snp.leading).offset(-10)
        }

        playingImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
    }
}
