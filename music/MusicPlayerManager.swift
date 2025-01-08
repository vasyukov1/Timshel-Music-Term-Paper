//
//  MusicPlayerManager.swift
//  music
//
//  Created by Alexander Vasyukov on 8/1/25.
//

import UIKit
import AVFoundation

class MusicPlayerManager: NSObject {
    static let shared = MusicPlayerManager()

    private var audioPlayer: AVAudioPlayer?
    private var trackQueue: [Track] = []
    private var currentTrack: Track?
    private var currentTrackIndex: Int?
    
    private let miniPlayer = MiniPlayerView()
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setCurrentTrack(_ track: Track) {
        currentTrack = track
        NotificationCenter.default.post(name: .trackDidChange, object: nil)
    }
    
    func getCurrentTrack() -> Track? {
        return currentTrack
    }
    
    func setQueue(traks: [Track]) {
        if (trackQueue.isEmpty) {
            trackQueue = traks
            currentTrackIndex = nil
        }
    }
    
    func playOrPauseTrack(_ track: Track) {
        if currentTrack != nil && currentTrack! == track {
            if let player = audioPlayer, player.isPlaying {
                player.pause()
                print("Track paused: \(track.title)")
            } else {
                audioPlayer?.play()
                print("Track resumed: \(track.title)")
            }
        } else if let index = trackQueue.firstIndex(of: track) {
            playTrack(at: index)
        } else {
            print("Track not found in queue")
        }
    }
    
    func playTrack(at index: Int) {
        guard 0 <= index && index < trackQueue.count else {
            print("Uncorrect index")
            return
        }
        
        let track = trackQueue[index]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: track.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            setCurrentTrack(track)
            currentTrackIndex = index
            print("Start playing track: \(track.title)")
        } catch {
            print("Error playing track: \(error)\n")
        }
        
    }
    
    func playNextTrack() {
        guard let index = currentTrackIndex, index + 1 < trackQueue.count else {
            print("No next track in queue")
            return
        }
        playTrack(at: index + 1)
    }
    
    func playPreviousTrack() {
        guard let index = currentTrackIndex, index > 0 else {
            print("No previous track in queue")
            return
        }
        playTrack(at: index - 1)
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentTrack = nil
        currentTrackIndex = nil
        print("Playback stopped")
    }
    
    @objc private func handleTrackEnd() {
        playNextTrack()
    }
}

extension MusicPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextTrack()
    }
}

extension Notification.Name {
    static let trackDidChange = Notification.Name("trackDidChange")
}
