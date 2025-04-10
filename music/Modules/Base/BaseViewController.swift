import UIKit
import Combine
import AVFoundation

class BaseViewController: UIViewController {
    
    private let viewModel = BaseViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private var loader: UIActivityIndicatorView?
    let toolbar = Toolbar()
    private let miniPlayer = MiniPlayerView.shared
    
    let buttonFont = UIFont(name: "SFProDisplay-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
    let labelFont = UIFont(name: "SFProDisplay-Semibold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupMiniPlayer()
        bindViewModel()
        
        view.backgroundColor = .black
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
        toolbar.backgroundColor = .black
        toolbar.barTintColor = .black
        toolbar.isTranslucent = false
        
        toolbar.setNavigationHandler(NavigationHandler(navigationController: navigationController))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "SFProDisplay-Semibold", size: 20) ?? .boldSystemFont(ofSize: 20)
        ]
        
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
            miniPlayer.heightAnchor.constraint(equalToConstant: 76)
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
    
    func configureButton(_ button: UIButton, title: String, font: UIFont) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        
        button.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.systemTeal.withAlphaComponent(0.8).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = 25
        button.layer.insertSublayer(gradient, at: 0)
        
        button.layer.shadowColor = UIColor.systemTeal.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        button.addTarget(self, action: #selector(animateButtonTap(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(animateButtonRelease(_:)), for: .touchUpInside)
    }
    
    @objc private func animateButtonTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.layer.shadowOpacity = 0.2
        }
    }
    
    @objc private func animateButtonRelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.layer.shadowOpacity = 0.3
        }
    }
}

extension UIView {
    func addGradientBackground(colors: [UIColor], cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = bounds
        gradientLayer.name = "GradientLayer"
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateGradientFrame() {
        layer.sublayers?
            .filter { $0.name == "GradientLayer" }
            .forEach { $0.frame = bounds }
    }
}
