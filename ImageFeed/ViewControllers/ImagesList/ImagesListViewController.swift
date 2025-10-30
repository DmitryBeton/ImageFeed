//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 13.08.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private var presenter: ImagesListPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter = ImagesListPresenter(view: self)
        presenter?.fetchNextPage()
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - ImagesListViewProtocol
extension ImagesListViewController: ImagesListViewProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.numberOfPhotos()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell,
            let presenter = presenter
        else { return UITableViewCell() }
        
        let photo = presenter.photo(at: indexPath)
        cell.delegate = self
        
        if let url = URL(string: photo.regularImageURL) {
            cell.setCellImage(with: url) { [weak self] in
                self?.reloadRow(at: indexPath)
            }
        }
        
        cell.setLabelDate(presenter.dateText(for: photo))
        cell.setLikeButtonImage(photo.isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return 0 }
        let photo = presenter.photo(at: indexPath)
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let width = tableView.bounds.width - insets.left - insets.right
        let scale = width / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let presenter = presenter else {
            return
        }
        if indexPath.row + 1 == presenter.numberOfPhotos() {
            presenter.fetchNextPage()
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter = presenter else {
            return
        }
        let photo = presenter.photo(at: indexPath)
        let singleVC = SingleImageViewController()
        if let url = URL(string: photo.largeImageURL) {
            singleVC.imageURL = url
        }
        singleVC.modalPresentationStyle = .fullScreen
        present(singleVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let presenter = presenter
        else { return }
        presenter.likePhoto(at: indexPath) { [weak self] isLiked in
            cell.setIsLiked(isLiked)
            self?.reloadRow(at: indexPath)
        }
    }
}
