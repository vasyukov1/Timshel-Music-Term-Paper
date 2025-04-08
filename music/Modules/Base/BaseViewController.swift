import UIKit
import Combine
import AVFoundation

class BaseViewController: UIViewController {
    
    private let viewModel = BaseViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var loader: UIActivityIndicatorView?
    let toolbar = Toolbar()
    private let miniPlayer = MiniPlayerView.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupMiniPlayer()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$isMiniPlayerVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isVisible in
                if isVisible {
                    self?.miniPlayer.show()
                } else {
                    self?.miniPlayer.hide()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$currentTrack
            .receive(on: DispatchQueue.main)
            .sink { [weak self] track in
                if let track = track {
                    self?.miniPlayer.configure(with: track)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupToolbar() {
        toolbar.setNavigationHandler(NavigationHandler(navigationController: navigationController))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupMiniPlayer() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(miniPlayer)
        
        NSLayoutConstraint.activate([
            miniPlayer.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 10),
            miniPlayer.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -10),
            miniPlayer.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            miniPlayer.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Loader Methods
    func showLoader() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.loader == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.color = .systemGray
                indicator.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(indicator)
                
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
                ])
                
                self.loader = indicator
            }
            
            self.loader?.startAnimating()
            self.view.bringSubviewToFront(self.loader!)
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.loader?.stopAnimating()
            self?.loader?.removeFromSuperview()
            self?.loader = nil
        }
    }
}
