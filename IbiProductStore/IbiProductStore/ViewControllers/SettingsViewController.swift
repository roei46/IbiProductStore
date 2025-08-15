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
    var cancellables = Set<AnyCancellable>() // To manage subscriptions
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
        
        firstLabel.text = viewModel.label
        secondLabel.text = viewModel.secondaryLabel
        logOutButton.setTitle(NSLocalizedString(viewModel.buttonLabel, comment: ""), for: .normal)

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
        
        // Listen for language changes
        NotificationCenter.default.publisher(for: .languageChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.firstLabel.text = self?.viewModel.label
                self?.secondLabel.text = self?.viewModel.secondaryLabel
                self?.logOutButton.setTitle(self?.viewModel.buttonLabel, for: .normal)
            }
            .store(in: &cancellables)
    }
}
