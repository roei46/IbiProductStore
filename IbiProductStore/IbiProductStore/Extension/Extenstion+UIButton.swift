//
//  Extenstion+UIButton.swift
//  IbiProductStore
//
//  Created by Roei Baruch on 14/08/2025.
//
import Foundation
import UIKit
import Combine

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
