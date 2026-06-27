//
//  AlbumViewController.swift
//  LspPlayer
//
//  Created by Alice Kamyshenko on 13.12.2025.
//

import UIKit

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var cardViewHeight: NSLayoutConstraint!

    private let dependencies = DependencyContainer.shared
    private lazy var viewModel = AlbumViewModel(
        repository: dependencies.trackRepository
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        viewModel.loadTracks()

        cardView.layer.cornerRadius = 22
        cardView.layer.masksToBounds = true

        tableView.backgroundColor = .clear
        tableView.rowHeight = 60
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = true
        tableView.contentInset.bottom = 8
        tableView.verticalScrollIndicatorInsets.bottom = 8

        imageView.layer.cornerRadius = 22


    }



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfTracks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TrackCell",
            for: indexPath
        ) as? TrackCell else {
            assertionFailure("TrackCell is not configured correctly")
            return UITableViewCell()
        }

        guard let track = viewModel.track(at: indexPath.row) else {
            return cell
        }

        cell.titleLabel.text = track.title
        cell.artistLabel.text = track.artist
        cell.coverImageView.image = UIImage(named: track.coverName)

        return cell
    }

    // вызывается когда пользователь тапает по ячейке
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let songVC = storyboard.instantiateViewController(
            withIdentifier: "SongViewController"
        ) as? SongViewController else {
            assertionFailure("SongViewController is not configured in Main.storyboard")
            return
        }

        guard let songViewModel = viewModel.makeSongViewModel(
            selectedIndex: indexPath.row,
            audioPlayerService: dependencies.audioPlayerService
        ) else {
            return
        }
        songVC.viewModel = songViewModel

        songVC.modalPresentationStyle = .pageSheet
        present(songVC, animated: true)
    }


    // вызывается после того, как Auto Layout расставил все view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Таблица занимает всё свободное место до safe area.
        // Если треки не помещаются, список становится прокручиваемым.
        tableView.layoutIfNeeded()

        let contentHeight = tableView.contentSize.height + tableView.contentInset.bottom
        let safeAreaBottom = view.bounds.height - view.safeAreaInsets.bottom
        let availableHeight = max(0, safeAreaBottom - cardView.frame.minY - 12)
        let visibleHeight = min(contentHeight, availableHeight)

        tableViewHeight.constant = visibleHeight
        cardViewHeight.constant = visibleHeight
        tableView.isScrollEnabled = contentHeight > availableHeight
    }
}
