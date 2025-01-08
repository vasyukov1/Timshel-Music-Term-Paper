//
//  MyMusicViewController.swift
//  music
//
//  Created by Alexander Vasyukov on 7/1/25.
//

import UIKit
import AVFoundation

class MyMusicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {

    private var tracks = [Track]()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        Task {
            tracks = await loadTracks()
            MusicPlayerManager.shared.setQueue(traks: self.tracks)
            tableView.reloadData()
        }
    }
    
    private func setupUI() {
        title = "My Music"
        view.backgroundColor = .systemBackground
        
        let toolbar = Toolbar()
        toolbar.navigationHandler = NavigationHandler(navigationController: navigationController)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: "TrackCell")
        view.addSubview(tableView)
        
        let addTrackButton = UIButton()
        addTrackButton.translatesAutoresizingMaskIntoConstraints = false
        addTrackButton.setTitle("Add Track", for: .normal)
        addTrackButton.backgroundColor = .systemBlue
        addTrackButton.addTarget(self, action: #selector(addTrack), for: .touchUpInside)
        view.addSubview(addTrackButton)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            addTrackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            addTrackButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addTrackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            addTrackButton.heightAnchor.constraint(equalToConstant: 40),
            
            
            tableView.topAnchor.constraint(equalTo: addTrackButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
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
        MusicPlayerManager.shared.playOrPauseTrack(selectedTrack)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func addTrack() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
}
