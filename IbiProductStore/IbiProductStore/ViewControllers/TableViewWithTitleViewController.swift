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
            let resetButton = UIButton(type: .system)
            resetButton.setTitle("Reset", for: .normal)
            resetButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            resetButton.tapPublisher
                .subscribe(viewModel.resetTrigger)
                .store(in: &cancellables)
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: resetButton)
            
            let addButton = UIButton(type: .system)
            addButton.setTitle("+", for: .normal)
            addButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            addButton.tapPublisher
                .sink { [weak self] in
                    self?.viewModel.addProduct()
                }
                .store(in: &cancellables)
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
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

    }
    
    private func loadInitialData() {
        viewModel.loadProducts()
    }
    
    // MARK: - Actions
    @objc private func refreshProducts() {
        viewModel.refreshData()
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
        
        viewModel.navigateToDetail(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []
        
        // Favorite action
        let product = viewModel.product(at: indexPath.row)
        let isFavorite = product.isFavorite
        
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
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel.deleteProduct(at: indexPath.row)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        actions.append(deleteAction)
        
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Check if we're near the bottom (last 5 rows) and not already loading
        let lastRowIndex = viewModel.numberOfProducts - 1
        let triggerDistance = 5
        
        if indexPath.row >= lastRowIndex - triggerDistance && !viewModel.isLoading {
            viewModel.loadMoreProducts()
        }
    }
}
