//
//  TableViewWithTitleViewController.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//

import UIKit
import Combine

class TableViewWithTitleViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var viewModel: any ProductListProtocol
    private var cancellables = Set<AnyCancellable>()
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshProducts), for: .valueChanged)
        return control
    }()
    
    // MARK: - Initialization
    init<T: ProductListProtocol>(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: "TableViewWithTitleViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
        loadInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshOnAppear()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        titleLabel.text = viewModel.screenTitle
        
        if viewModel.canEdit() {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Reset",
                style: .plain,
                target: self,
                action: #selector(resetTapped)
            )
        }
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        // Register custom cell
        let nib = UINib(nibName: "ProductTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ProductTableViewCell.identifier)
    }
    
    private func setupBindings() {
        // Observe cell view models changes
        viewModel.cellViewModelsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        // Observe loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Observe error messages
        viewModel.errorMessagePublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        viewModel.loadProducts()
    }
    
    // MARK: - Actions
    @objc private func refreshProducts() {
        viewModel.refreshData()
    }
    
    @objc private func resetTapped() {
        let alert = UIAlertController(
            title: "Reset Products",
            message: "This will reset all changes and reload from server. Are you sure?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.viewModel.resetToServer()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TableViewWithTitleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.cellViewModel(at: indexPath.row)
        cell.configure(with: cellViewModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TableViewWithTitleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let product = viewModel.product(at: indexPath.row)
        navigateToProductDetail(product: product)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        
        // Favorite action
        let product = viewModel.product(at: indexPath.row)
        let isFavorite = viewModel.isFavorite(product)
        
        let favoriteAction = UIContextualAction(
            style: .normal,
            title: isFavorite ? "Unfavorite" : "Favorite"
        ) { [weak self] _, _, completion in
            self?.viewModel.toggleFavorite(at: indexPath.row)
            completion(true)
        }
        favoriteAction.backgroundColor = isFavorite ? .systemOrange : .systemBlue
        favoriteAction.image = UIImage(systemName: isFavorite ? "heart.slash" : "heart")
        actions.append(favoriteAction)
        
        // Delete action (only for editable lists)
        if viewModel.canEdit() {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
                self?.confirmDelete(at: indexPath, completion: completion)
            }
            deleteAction.image = UIImage(systemName: "trash")
            actions.append(deleteAction)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard viewModel.canEdit() else { return nil }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            self?.editProduct(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = .systemGreen
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    // MARK: - Helper Methods
    private func navigateToProductDetail(product: Product) {
        // TODO: Implement product detail navigation
        print("Navigate to product detail: \(product.title)")
    }
    
    private func confirmDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let product = viewModel.product(at: indexPath.row)
        
        let alert = UIAlertController(
            title: "Delete Product",
            message: "Are you sure you want to delete \(product.title)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteProduct(at: indexPath.row)
            completion(true)
        })
        
        present(alert, animated: true)
    }
    
    private func editProduct(at indexPath: IndexPath) {
        // TODO: Implement product editing in edit screen!!! very importent!!!!!!!!!!!!!!!!!
        let product = viewModel.product(at: indexPath.row)
        print("Edit product: \(product.title)")
    }
}
