//
//  SettingsViewController.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 15/08/2025.
//

import UIKit
import Combine

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var firstSwitch: UISwitch!
    @IBOutlet weak var secondSwitch: UISwitch!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SettingsViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial title
        title = "settings".localized
        
        // Update title when language changes
        UserDefaultsService.shared.$currentLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.title = "settings".localized
            }
            .store(in: &cancellables)
        
        // Bind labels to ViewModel published properties
        viewModel.$label
            .receive(on: DispatchQueue.main)
            .map { $0 as String? }
            .assign(to: \.text, on: firstLabel)
            .store(in: &cancellables)
        
        viewModel.$secondaryLabel
            .receive(on: DispatchQueue.main)
            .map { $0 as String? }
            .assign(to: \.text, on: secondLabel)
            .store(in: &cancellables)
        
        viewModel.$buttonLabel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] buttonText in
                self?.logOutButton.setTitle(buttonText, for: .normal)
            }
            .store(in: &cancellables)

        // Bind ViewModel state to UI switches
        viewModel.$isFirstSwitchOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.firstSwitch.isOn = isOn
            }
            .store(in: &cancellables)
            
        viewModel.$isSecondSwitchOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.secondSwitch.isOn = isOn
            }
            .store(in: &cancellables)
        
        // Bind UI switch changes to ViewModel
        firstSwitch?.publisher(for: .valueChanged)
            .compactMap { $0 as? UISwitch }
            .map(\.isOn)
            .assign(to: \.isFirstSwitchOn, on: viewModel)
            .store(in: &cancellables)
        
        secondSwitch?.publisher(for: .valueChanged)
            .compactMap { $0 as? UISwitch }
            .map(\.isOn)
            .assign(to: \.isSecondSwitchOn, on: viewModel)
            .store(in: &cancellables)
        
        logOutButton.tapPublisher
            .subscribe(viewModel.logOutTrigger)
            .store(in: &cancellables)
    }
}
