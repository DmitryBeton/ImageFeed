import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let profileImage = UIImage(resource: .logoOfUnsplash)
        let imageView = UIImageView(image: profileImage)
        return imageView
    }()
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(presentWebViewViewController), for: .touchUpInside)
        return button
    }()
    // MARK: - Properties
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        setupUI()
        setupConstrains()
    }
    
    // MARK: - Methods
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    @objc private func presentWebViewViewController() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        print("🔑 Received auth code:", code)
        
        UIBlockingProgressHUD.show()
        
        self.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("✅ Auth completed successfully!")
                vc.dismiss(animated: true) {
                    self.delegate?.didAuthenticate(self)
                }
            case let .failure(error):
                print("❌ Auth failed: \(error.localizedDescription)")
                self.showAuthErrorAlert()
                break
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        view.addSubview(imageView)
        view.addSubview(loginButton)
    }
    
    // MARK: - Layout
    func setupConstrains() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor) .isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor) .isActive = true
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
    
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошла не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
