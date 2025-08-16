//
//  Extenstion+UIButton.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//
import Foundation
import UIKit
import Combine
import Lottie

extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        publisher(for: .touchUpInside)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    private var isCurrentlyLoading: Bool {
        return subviews.contains { $0 is LottieAnimationView || $0 is UIActivityIndicatorView }
    }
    
    func bindLoading<T: Publisher>(
        to publisher: T,
        animationName: String,
        cancellables: inout Set<AnyCancellable>
    ) where T.Output == Bool, T.Failure == Never {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                print("🔄 Button received loading state: \(isLoading)")
                if isLoading {
                    print("📱 Showing loading on button...")
                    self?.showLoading(animationName: animationName)
                } else {
                    print("📱 Hiding loading on button...")
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showLoading(animationName: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.isCurrentlyLoading else { return }
            
            let originalTitle = self.title(for: .normal)
            self.accessibilityValue = originalTitle
            
            self.setTitle("", for: .normal)
            self.isUserInteractionEnabled = false
            
            let loader = LottieAnimationView(name: animationName)
            
            if loader.animation == nil {
                print("⚠️ Lottie animation '\(animationName)' not found")
                self.showActivityIndicator()
                return
            }
            
            loader.loopMode = .loop
            loader.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(loader)
            
            NSLayoutConstraint.activate([
                loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                loader.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                loader.heightAnchor.constraint(equalToConstant: 24),
                loader.widthAnchor.constraint(equalToConstant: 24)
            ])
            
            loader.play()
        }
    }
    
    private func showActivityIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        self.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        indicator.startAnimating()
    }
    
    private func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.isCurrentlyLoading else { return }
            
            self.subviews.compactMap { $0 as? LottieAnimationView }.forEach {
                $0.stop()
                $0.removeFromSuperview()
            }
            self.subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach {
                $0.removeFromSuperview()
            }
            
            let originalTitle = self.accessibilityValue
            self.setTitle(originalTitle, for: .normal)
            self.accessibilityValue = nil // Clear temporary storage
            self.isUserInteractionEnabled = true
        }
    }
    
    func prepareForReuse() {
        hideLoading()
    }
}
