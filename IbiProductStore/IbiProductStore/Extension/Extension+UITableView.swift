//
//  Extension+UITableView.swift
//  IbiProductStore
//
//  Created by Claude Code on 16/08/2025.
//

import UIKit
import Lottie

extension UITableView {
    
    private var loadingView: UIView? {
        get { return viewWithTag(999) }
        set {
            loadingView?.removeFromSuperview()
            if let newValue = newValue {
                newValue.tag = 999
                addSubview(newValue)
            }
        }
    }
    
    private var emptyStateView: UIView? {
        get { return viewWithTag(998) }
        set {
            emptyStateView?.removeFromSuperview()
            if let newValue = newValue {
                newValue.tag = 998
                addSubview(newValue)
            }
        }
    }
    
    // MARK: - Loading State
    func showLoading(animationName: String = "viewLoader") {
        hideEmptyState()
        
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let loader = LottieAnimationView(name: animationName)
        if loader.animation == nil {
            showActivityIndicatorLoading()
            return
        }
        
        loader.loopMode = .loop
        loader.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loader)
        
        let loadingLabel = UILabel()
        loadingLabel.text = "loading".localized
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.font = UIFont.systemFont(ofSize: 16)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingLabel)
        
        loadingView = containerView
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            loader.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loader.topAnchor.constraint(equalTo: containerView.topAnchor),
            loader.widthAnchor.constraint(equalToConstant: 80),
            loader.heightAnchor.constraint(equalToConstant: 80),
            
            loadingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8),
            loadingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        loader.play()
    }
    
    private func showActivityIndicatorLoading() {
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .label
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        let loadingLabel = UILabel()
        loadingLabel.text = "loading".localized
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.font = UIFont.systemFont(ofSize: 16)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingLabel)
        
        loadingView = containerView
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor),
            
            loadingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            loadingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingView?.subviews.compactMap { $0 as? LottieAnimationView }.forEach { $0.stop() }
        loadingView = nil
    }
    
    // MARK: - Empty State
    func showEmptyState(title: String, subtitle: String? = nil, imageName: String? = nil) {
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Image (optional)
        if let imageName = imageName {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: imageName)
            imageView.tintColor = .tertiaryLabel
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 60),
                imageView.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .secondaryLabel
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stackView.addArrangedSubview(titleLabel)
        
        // Subtitle (optional)
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = .tertiaryLabel
            subtitleLabel.font = UIFont.systemFont(ofSize: 14)
            subtitleLabel.textAlignment = .center
            subtitleLabel.numberOfLines = 0
            stackView.addArrangedSubview(subtitleLabel)
        }
        
        emptyStateView = containerView
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    func hideEmptyState() {
        emptyStateView = nil
    }
}
