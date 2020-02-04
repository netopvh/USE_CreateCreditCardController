//
//  Button.swift
//
//  Created by Claudio Madureira Silva Filho on 10/12/18.
//  Copyright © 2018 Claudio Madureira Silva Filho. All rights reserved.
//

import UIKit

public enum ButtonState {
    case highlighted
    case normal
}

public class Button: UIButton {
    
    public var _state: ButtonState = .normal
    public var didChangeState: ((Button, ButtonState) -> Void)?
    public var performOnPressed: ((Button) -> Void)?
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        self.addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        self.addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(didTouchDragInside), for: .touchDragInside)
        self.addTarget(self, action: #selector(didTouchUpOutside), for: .touchDragOutside)
    }
    
    @objc private func didTouchDown() {
        self.perform(state: .highlighted)
    }
    
    @objc private func didTouchDragInside() {
        self.perform(state: .highlighted)
    }
    
    @objc private func didTouchUpInside() {
        self.perform(state: .normal)
        self.performOnPressed?(self)
    }
    
    @objc private func didTouchUpOutside() {
        self.perform(state: .normal)
    }
    
    private func perform(state: ButtonState) {
        self._state = state
        self.didChangeState?(self, state)
    }
    
}
