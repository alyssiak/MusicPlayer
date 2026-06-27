//
//  AudioSessionService.swift
//  LspPlayer
//
//  Created by Alice Kamyshenko on 27.06.2026.
//

import AVFoundation

protocol AudioSessionConfiguring {
    func active() throws
}

final class AudioSessionService: AudioSessionConfiguring {
    func active() throws {
        let session = AVAudioSession.sharedInstance()

        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }
}
