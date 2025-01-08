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
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    func playOrPauseTrack(_ track: Track) {
        if let index = trackQueue.firstIndex(of: track) {
            currentTrackIndex = index
            playTrack(at: index)
//        if currentTrack != nil && currentTrack! == track {
//            if let player = audioPlayer, player.isPlaying {
//                player.pause()
//                print("Track paused: \(track.title)")
//            } else {
//                audioPlayer?.play()
//                print("Track resumed: \(track.title)")
//            }
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
            currentTrack = track
            currentTrackIndex = index
            print("Start playing track: \(track.title)")
        } catch {
            print("Error playing track: \(error)\n")
        }
        
    }
    
    func setQueue(traks: [Track]) {
        trackQueue = traks
        currentTrackIndex = nil
    }
    
    func playNextTrack() {
        guard let index = currentTrackIndex, index + 1 < trackQueue.count else {
            print("No next track in queue")
            return
        }
        playTrack(at: index + 1)
    }
    
    func playPreviousTrack() {
        guard let index = currentTrackIndex, index  > 0 else {
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
