# MusicPlayer

An iOS music player built with Swift, UIKit and AVFoundation.

## Architecture

The project uses MVVM with protocol-based dependencies:

- `AudioPlayerService` isolates AVFoundation playback;
- `TrackRepository` provides the music catalogue;
- feature-specific ViewModels own presentation logic;
- `DependencyContainer` assembles the app dependencies.

## Features

- local track catalogue;
- play, pause, seek and volume controls;
- next and previous track navigation;
- shuffle and repeat modes;
- persistent mini-player shared with the full player screen;
- adaptive scrollable album layout;
- share current track.

## Tech stack

- Swift 5
- UIKit and SnapKit
- AVFoundation
- MVVM
- Dependency injection

## Local setup

Open `LspPlayer.xcodeproj` in Xcode. Audio files are intentionally excluded from
the public repository. To test playback, add licensed demo MP3 files to
`LspPlayerApp/Music` using the filenames declared in `LocalTrackRepository`.
