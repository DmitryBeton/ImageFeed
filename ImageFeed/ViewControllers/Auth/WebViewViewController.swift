import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    // MARK: - UI Elements
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.overrideUserInterfaceStyle = .light
        webView.accessibilityIdentifier = "UnsplashWebView"
        return webView
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .black
        return progressView
    }()
    
    private lazy var backButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(resource: .navBackButton),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        button.tintColor = .black
        return button
    }()
    
    // MARK: - Properties
    var presenter: WebViewPresenterProtocol?
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupWebView()
        
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
    }
    
    deinit {
        estimatedProgressObservation = nil
    }
    
    // MARK: - Methods
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
        
//        estimatedProgressObservation = webView.observe(
//            \.estimatedProgress,
//             options: [],
//             changeHandler: { _, _ in
//                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
//             })
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    @objc private func didTapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            print("✅ Received auth code: \(code)")
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            if let url = navigationAction.request.url {
                print("🌐 Navigating to: \(url.absoluteString)")
            }
            decisionHandler(.allow)
        }
    }
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            webView.addObserver(
                self,
                forKeyPath: #keyPath(WKWebView.estimatedProgress),
                options: .new,
                context: nil)
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        }
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
