import Foundation

class ProfileViewModel {
    
    var topTracks: [Track] = []
    var topArtists: [ArtistStats] = []
    
    func loadStatsData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.topTracks = []
            self.topArtists = []
            completion()
        }
    }
    
    func getUserName() -> String {
        return UserDefaults.standard.string(forKey: "savedLogin") ?? "Гость"
    }
}
