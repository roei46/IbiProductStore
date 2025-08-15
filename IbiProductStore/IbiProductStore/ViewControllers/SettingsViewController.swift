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
    private var viewModel: any SettingsType
    
    init(viewModel: any SettingsType) {
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
