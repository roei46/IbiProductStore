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

extension UIControl {
    func publisher(for event: UIControl.Event) -> UIControlPublisher {
        return UIControlPublisher(control: self, event: event)
    }
}

struct UIControlPublisher: Publisher {
    typealias Output = UIControl
    typealias Failure = Never
    
    let control: UIControl
    let event: UIControl.Event
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIControl == S.Input {
        let subscription = UIControlSubscription(control: control, event: event, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

final class UIControlSubscription<S: Subscriber>: Subscription where S.Input == UIControl, S.Failure == Never {
    private var subscriber: S?
    private let control: UIControl
    
    init(control: UIControl, event: UIControl.Event, subscriber: S) {
        self.control = control
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        subscriber = nil
    }
    
    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }
}

extension UIButton {
    var tapPublisher: AnyPublisher<Void, Never> {
        publisher(for: .touchUpInside)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

extension UIButton {
    
    private var isCurrentlyLoading: Bool {
        return subviews.contains { $0 is LottieAnimationView || $0 is UIActivityIndicatorView }
    }
    
    func bindLoading<P: Publisher>(
        to publisher: P,
        animationName: String,
        cancellables: inout Set<AnyCancellable>
    ) where P.Output == Bool, P.Failure == Never {
        
        // Clean Swift approach - caller manages the subscription
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
            
            // Store original title in accessibility identifier temporarily
            let originalTitle = self.title(for: .normal)
            self.accessibilityValue = originalTitle
            
            // Clear button text and disable interaction
            self.setTitle("", for: .normal)
            self.isUserInteractionEnabled = false
            
            // Create and configure Lottie animation
            let loader = LottieAnimationView(name: animationName)
            
            // Handle case where animation file doesn't exist
            if loader.animation == nil {
                print("⚠️ Lottie animation '\(animationName)' not found")
                // Fallback to simple activity indicator
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
        let indicator = UIActivityIndicatorView(style: .large) // Larger size
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white // Force white color for visibility
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
            
            // Stop and remove all loading views
            self.subviews.compactMap { $0 as? LottieAnimationView }.forEach { 
                $0.stop()
                $0.removeFromSuperview() 
            }
            self.subviews.compactMap { $0 as? UIActivityIndicatorView }.forEach { 
                $0.removeFromSuperview() 
            }
            
            // Restore original state
            let originalTitle = self.accessibilityValue
            self.setTitle(originalTitle, for: .normal)
            self.accessibilityValue = nil // Clear temporary storage
            self.isUserInteractionEnabled = true
        }
    }
    
    // Call this when button is no longer needed
    func prepareForReuse() {
        hideLoading()
    }
}
