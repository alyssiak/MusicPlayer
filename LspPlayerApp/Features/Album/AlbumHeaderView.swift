import SnapKit
import UIKit

final class AlbumHeaderView: UIView {
    private let artworkContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.28
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        return view
    }()

    private let artworkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "6"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Судный день"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "GillSans-SemiBold", size: 30)
            ?? .systemFont(ofSize: 30, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.text = "ЛСП"
        label.textAlignment = .center
        label.textColor = .white.withAlphaComponent(0.68)
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let descriptionCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.065)
        view.layer.cornerRadius = 14
        return view
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Альбом, в котором за легкими танцевальными ритмами скрывается мрачная, исповедальная история."
        label.textColor = .white.withAlphaComponent(0.72)
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("AlbumHeaderView is created programmatically")
    }

    private func configureUI() {
        addSubview(artworkContainerView)
        artworkContainerView.addSubview(artworkImageView)
        addSubview(titleLabel)
        addSubview(artistLabel)
        addSubview(descriptionCardView)
        descriptionCardView.addSubview(descriptionLabel)

        artworkContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(280).priority(.high)
            make.width.lessThanOrEqualToSuperview().inset(32)
            make.height.equalTo(artworkContainerView.snp.width)
        }

        artworkImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(artworkContainerView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        artistLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }

        descriptionCardView.snp.makeConstraints { make in
            make.top.equalTo(artistLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(80)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}
