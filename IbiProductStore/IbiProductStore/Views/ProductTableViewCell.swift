//
//  ProductTableViewCell.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import UIKit
import Combine

class ProductTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "ProductTableViewCell"
    private var viewModel: ProductCellViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
        viewModel = nil
        thumbnailImageView.image = nil
        titleLabel.text = nil
        brandLabel.text = nil
        descriptionLabel.text = nil
        priceLabel.text = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .gray
        
        // Configure image view
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .systemGray6
        
        // Add subtle shadow to the cell
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
    }
    
    // MARK: - Configuration
    func configure(with cellViewModel: ProductCellViewModel) {
        // Use the provided view model
        self.viewModel = cellViewModel
        
        // Bind data
        bindViewModel()
        
        // Load thumbnail if not already loaded
        viewModel?.loadThumbnailImage()
    }
    
    // Legacy method for backward compatibility
    func configure(with product: Product) {
        let cellViewModel = ProductCellViewModel(product: product)
        configure(with: cellViewModel)
    }
    
    // MARK: - Binding
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        // Set static data
        titleLabel.text = viewModel.title
        brandLabel.text = viewModel.brand
        descriptionLabel.text = viewModel.description
        priceLabel.attributedText = viewModel.getPriceAttributedString()
        
        // Bind thumbnail image
        viewModel.$thumbnailImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.thumbnailImageView.image = image ?? UIImage(systemName: "photo")
            }
            .store(in: &cancellables)
        
        // Bind loading state (optional: add loading indicator)
        viewModel.$isImageLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // You can add a loading spinner here if needed
                self?.thumbnailImageView.alpha = isLoading ? 0.5 : 1.0
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func getProduct() -> Product? {
        return viewModel?.getProduct()
    }
}
