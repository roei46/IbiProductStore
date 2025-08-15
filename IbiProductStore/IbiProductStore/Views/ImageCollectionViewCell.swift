//
//  ImageCollectionViewCell.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import UIKit
import SDWebImage

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    static let identifier = "ImageCollectionViewCell"
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.startAnimating()
    }
    
    // MARK: - Setup
    private func setupCell() {
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemGray6
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    // MARK: - Configuration
    func configure(with imageUrl: String) {
        imageView.image = nil
        activityIndicator.startAnimating()
        
        guard let url = URL(string: imageUrl) else {
            activityIndicator.stopAnimating()
            return
        }
        
        imageView.sd_setImage(with: url, placeholderImage: nil) { [weak self] _, _, _, _ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}