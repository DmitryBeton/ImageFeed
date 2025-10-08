//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 16.08.2025.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    // MARK: - UI Elements
    private let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .likeButtonOn), for: .normal)
        button.addTarget(self,
                         action: #selector(didLiked),
                         for: .touchUpInside)
        return button
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Нижние углы
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        // FIX: - gradient
        //        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    private func setupUI() {
        backgroundColor = .ypBlack
        selectionStyle = .none
        
        contentView.addSubview(cellImage)
        contentView.addSubview(gradientView)
        gradientView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
    }
    
    private func setupConstraints() {
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            gradientView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30),
            
            dateLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -8),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didLiked() {
        
    }
    // MARK: - Public methods
    public func setLabelDate(_ text: String) {
        dateLabel.text = text
    }
    
    public func setCellImage(_ image: UIImage) {
        cellImage.image = image
    }
    
    public func setCellImage(with url: URL) {
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    public func setLikeButtonImage(_ image: UIImage) {
        likeButton.setImage(image, for: .normal)
    }
    
    // MARK: - Gradient Setup
    //    private func setupGradient() {
    //        gradientView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    //        let gradientLayer = CAGradientLayer()
    //        gradientLayer.frame = gradientView.bounds
    //        gradientLayer.colors = [
    //            UIColor.black.withAlphaComponent(0.0).cgColor,
    //            UIColor.black.withAlphaComponent(0.4).cgColor
    //        ]
    //        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    //        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    //        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    //        
    //        gradientView.layer.cornerRadius = 16
    //        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Нижние углы
    //        gradientView.layer.masksToBounds = true
    //    }
}
