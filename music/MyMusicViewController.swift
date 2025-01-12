//
//  MyMusicViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit
import AVFoundation

class MyMusicViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {

    private var tracks = [Track]()
    private let tableView = UITableView()
    private let addTrackButton = UIButton()
    
    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
        Task {
            tracks = await loadTracks()
            MusicPlayerManager.shared.setQueue(tracks: self.tracks)
            tableView.reloadData()
        }
    }
    
    private func setupUI() {
        title = "My Music"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        addTrackButton.setTitle("Add Tracks", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.layer.cornerRadius = 8
        addTrackButton.addTarget(self, action: #selector(addTrack), for: .touchUpInside)
        view.addSubview(addTrackButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addTrackButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addTrackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.row]
        MusicPlayerManager.shared.startPlaying(track: selectedTrack)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func addTrack() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
}
