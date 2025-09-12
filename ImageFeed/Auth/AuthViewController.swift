import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showWebViewSegueIdentifier,
            let webViewViewController = segue.destination as? WebViewViewController
        else {
            assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
            super.prepare(for: segue, sender: sender)
            return
        }
        webViewViewController.delegate = self
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure:
                break
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

extension AuthViewController {
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        oauth2Service.fetchOAuthToken(code) { result in
            completion(result)
        }
    }
}

