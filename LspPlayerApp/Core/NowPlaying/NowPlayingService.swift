//
//  NowPlayingService.swift
//  LspPlayer
//
//  Created by Alice Kamyshenko on 27.06.2026.
//

import MediaPlayer
import UIKit

protocol NowPlayingInfoUpdating {
    func update(
        track: Track,
        elapsedTime: TimeInterval,
        duration: TimeInterval,
        isPlaying: Bool
    )

    func configureRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onSeek: @escaping (TimeInterval) -> Void
    )
}

final class NowPlayingService: NowPlayingInfoUpdating {
    private let infoCenter = MPNowPlayingInfoCenter.default()
    private var artworkCache: [String: MPMediaItemArtwork] = [:]
    private let commandCenter = MPRemoteCommandCenter.shared()
    private var commandTargets: [Any] = []

    func update(
    track: Track,
    elapsedTime: TimeInterval,
    duration: TimeInterval,
    isPlaying: Bool
    ) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: "Судный день",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1 : 0
        ]

        if let artwork = makeArtwork(for: track) {
            info[MPMediaItemPropertyArtwork] = artwork
        }

        infoCenter.nowPlayingInfo = info
    }

    func configureRemoteCommands(
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onSeek: @escaping (TimeInterval) -> Void
    ) {
        guard commandTargets.isEmpty else { return }

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.seekForwardCommand.isEnabled = true

        commandTargets.append(
            commandCenter.playCommand.addTarget { _ in
                DispatchQueue.main.async {
                    onPlay()
                }
                return .success
            }
        )

        commandTargets.append(
                commandCenter.pauseCommand.addTarget { _ in
                    DispatchQueue.main.async {
                        onPause()
                    }
                    return .success
                }
            )

            commandTargets.append(
                commandCenter.nextTrackCommand.addTarget { _ in
                    DispatchQueue.main.async {
                        onNext()
                    }
                    return .success
                }
            )

            commandTargets.append(
                commandCenter.previousTrackCommand.addTarget { _ in
                    DispatchQueue.main.async {
                        onPrevious()
                    }
                    return .success
                }
            )

            commandTargets.append(
                commandCenter.changePlaybackPositionCommand.addTarget { event in
                    guard let positionEvent =
                        event as? MPChangePlaybackPositionCommandEvent
                    else {
                        return .commandFailed
                    }

                    DispatchQueue.main.async {
                        onSeek(positionEvent.positionTime)
                    }

                    return .success
                }
            )
    }

    private func makeArtwork(for track: Track) -> MPMediaItemArtwork? {
        if let cachedArtwork = artworkCache[track.coverName] {
            return cachedArtwork
        }

        guard let image = UIImage(named: track.coverName) else {
            return nil
        }

        let artwork = MPMediaItemArtwork(
            boundsSize: image.size
        ) { _ in
            image
        }

        artworkCache[track.coverName] = artwork
        return artwork
    }
}
