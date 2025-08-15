//
//  DetailsViewController.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import UIKit
import Combine

class DetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Properties
    private let viewModel: any DetailsProtocol
    private var cancellables = Set<AnyCancellable>()
    private let closeButton = UIButton()
    
    // MARK: - Initialization
    init(viewModel: any DetailsProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "DetailsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupBindings()
        configureContent()
        
        // Ensure navigation bar is visible
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        title = "Details"
        
        // Navigation - custom close button to support tapPublisher
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        // Initialize button states (not editing initially)
        editButton.isHidden = false
        saveButton.isHidden = true
        cancelButton.isHidden = true
        
        // Style text fields (initially in view mode)
        titleTextField.font = .boldSystemFont(ofSize: 24)
        titleTextField.isUserInteractionEnabled = false
        titleTextField.borderStyle = .none
        titleTextField.backgroundColor = .clear
        
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        
        priceTextField.font = .boldSystemFont(ofSize: 20)
        priceTextField.textColor = .systemGreen
        priceTextField.isUserInteractionEnabled = false
        priceTextField.borderStyle = .none
        priceTextField.backgroundColor = .clear
        priceTextField.keyboardType = .decimalPad
        priceTextField.autocorrectionType = .no
        priceTextField.spellCheckingType = .no
        
        // Add done button to price text field toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, doneButton]
        priceTextField.inputAccessoryView = toolbar
        
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.backgroundColor = .systemGray6
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.isEditable = false
        
        // Buttons
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .systemRed
        
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .systemBlue
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        imagesCollectionView.collectionViewLayout = layout
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.showsHorizontalScrollIndicator = false
        
        // Register cell from XIB
        let nib = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        imagesCollectionView.register(nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
    }
    
    private func setupBindings() {
        // Bind favorite state and edit state using assign
        viewModel.isFavoritePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: favoriteButton)
            .store(in: &cancellables)
        
        viewModel.isEditingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing in
                self?.updateEditMode(isEditing)
            }
            .store(in: &cancellables)
        
        // Two-way binding using textPublisher (like LoginViewController)
        titleTextField.textPublisher
            .compactMap { $0 }
            .assign(to: \.editableTitle, on: viewModel)
            .store(in: &cancellables)
        
        priceTextField.textPublisher
            .compactMap { $0 }
            .assign(to: \.editablePrice, on: viewModel)
            .store(in: &cancellables)
        
        // Bind view model changes back to UI using assign with map
        viewModel.editableTitlePublisher
            .receive(on: DispatchQueue.main)
            .map { $0 as String? }
            .assign(to: \.text, on: titleTextField)
            .store(in: &cancellables)
        
        viewModel.editablePricePublisher
            .receive(on: DispatchQueue.main)
            .map { $0 as String? }
            .assign(to: \.text, on: priceTextField)
            .store(in: &cancellables)
        
        viewModel.editableDescriptionPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: descriptionTextView)
            .store(in: &cancellables)
        
        // Add text view delegate for description changes
        descriptionTextView.delegate = self
        
        // Bind button taps to view model actions
        editButton.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel.edit()
            }
            .store(in: &cancellables)
        
        saveButton.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.saveChanges()
                self?.configureContent()
            }
            .store(in: &cancellables)
        
        cancelButton.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.cancelEditing()
            }
            .store(in: &cancellables)
        
        // Bind close button exactly like login pattern
        closeButton.tapPublisher
            .subscribe(viewModel.closeTrigger)
            .store(in: &cancellables)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureContent() {
        titleTextField.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        priceTextField.text = viewModel.price
        descriptionTextView.text = viewModel.description
        favoriteButton.isSelected = viewModel.isFavorite
        
        // Hide subtitle if empty
        subtitleLabel.isHidden = viewModel.subtitle?.isEmpty ?? true
        
        // Hide price if empty
        priceTextField.isHidden = viewModel.price?.isEmpty ?? true
    }
    
    // MARK: - Actions
    @IBAction private func favoriteTapped(_ sender: UIButton) {
        viewModel.toggleFavorite()
        
        // Add animation
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                sender.transform = .identity
            }
        }
    }
    
    @IBAction private func shareTapped(_ sender: UIButton) {
        let shareText = viewModel.shareContent()
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateEditMode(_ isEditing: Bool) {
        if isEditing {
            // Enable text field interaction
            titleTextField.isUserInteractionEnabled = true
            titleTextField.borderStyle = .roundedRect
            titleTextField.backgroundColor = .systemBackground
            
            priceTextField.isUserInteractionEnabled = true
            priceTextField.borderStyle = .roundedRect
            priceTextField.backgroundColor = .systemBackground
            
            descriptionTextView.isEditable = true
            descriptionTextView.backgroundColor = .systemBackground
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
            
            // Show save and cancel buttons, hide edit button
            editButton.isHidden = true
            saveButton.isHidden = false
            cancelButton.isHidden = false
            
            // Focus on title field
            titleTextField.becomeFirstResponder()
        } else {
            // Disable text field interaction (styled as labels)
            titleTextField.isUserInteractionEnabled = false
            titleTextField.borderStyle = .none
            titleTextField.backgroundColor = .clear
            
            priceTextField.isUserInteractionEnabled = false
            priceTextField.borderStyle = .none
            priceTextField.backgroundColor = .clear
            
            descriptionTextView.isEditable = false
            descriptionTextView.backgroundColor = .systemGray6
            descriptionTextView.layer.borderWidth = 0
            
            // Show edit button, hide save and cancel buttons
            editButton.isHidden = false
            saveButton.isHidden = true
            cancelButton.isHidden = true
            
            // Dismiss keyboard
            view.endEditing(true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DetailsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        
        let imageUrl = viewModel.imageUrls[indexPath.item]
        cell.configure(with: imageUrl)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DetailsViewController: UICollectionViewDelegate {
    // Future: Add image preview functionality
}

// MARK: - UITextViewDelegate
extension DetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView == descriptionTextView,
           let editableViewModel = viewModel as? ProductDetailViewModel {
            editableViewModel.editableDescription = textView.text
        }
    }
}
