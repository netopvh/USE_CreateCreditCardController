//
//  AlertCreateCardView.swift
//
//  Created by Claudio Madureira Silva Filho on 15/01/19.
//

import UIKit

enum AlertType {
    case noButton
    case singleButton(String, (() -> Void))
    case doubleButton(String, String, (() -> Void))
    
    var isNoButtonType: Bool {
        switch self {
        case .noButton:
            return true
        default:
            return false
        }
    }
    
    var isSingleButtonType: Bool {
        switch self {
        case .singleButton:
            return true
        default:
            return false
        }
    }
    
    var isDoubleButtonType: Bool {
        switch self {
        case .doubleButton:
            return true
        default:
            return false
        }
    }
}

class AlertCreateCardView: UIView {
    
    var type: AlertType = .noButton
    var label: UILabel = UILabel()
    var completion: (() -> Void)?
    var propertyAnimator: Any?
    
    convenience init(text: String, type: AlertType) {
        let colors = CreateCardViewController.configuration.colors
        let screenSize = UIScreen.main.bounds.size
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let buttonHeight: CGFloat = 45
        let buttonPaddingBottom: CGFloat = 12
        let size = CGSize(width: screenSize.width, height: statusBarHeight + 80 + (type.isNoButtonType ? 0 : buttonHeight + buttonPaddingBottom))
        let frame = CGRect(origin: .zero, size: size)
        self.init(frame: frame)
        self.type = type
        self.frame.origin.y = -size.height - 2
        self.layer.shadowColor = colors.alertShadow.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.4
        
        let label = self.label
        label.text = text
        label.numberOfLines = 2
        label.frame.size = CGSize(width: screenSize.width*0.87, height: 70)
        label.font = CreateCardViewController.configuration.fonts.alertTitle
        label.frame.origin.y = statusBarHeight + 8
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        label.center.x = size.width/2
        switch type {
        case .noButton:
            self.backgroundColor = colors.alertNoButtonBackground
            label.textColor = colors.alertNoButtonTitle
        case let .singleButton(title, action):
            self.completion = action
            self.backgroundColor = colors.alertSingleButtonBackground
            label.textColor = colors.alertSingleButtonTitle
            let padding = label.frame.origin.x
            let buttonSize = CGSize(width: (screenSize.width - 3*padding)/2, height: buttonHeight)
            let buttonOriginY = self.frame.height - buttonHeight - buttonPaddingBottom
            let buttonOK = Button()
            buttonOK.frame.size = buttonSize
            buttonOK.layer.masksToBounds = true
            buttonOK.layer.cornerRadius = 5
            buttonOK.frame.origin.y = buttonOriginY
            buttonOK.center.x = screenSize.width/2
            buttonOK.backgroundColor = colors.alertSingleButton_ButtonBackground
            buttonOK.titleLabel?.font = CreateCardViewController.configuration.fonts.alertButtons
            buttonOK.setTitle(title, for: .normal)
            buttonOK.setTitleColor(colors.alertSingleButton_ButtonTitle, for: .normal)
            buttonOK.didChangeState = { _, state in
                buttonOK.alpha = state == .highlighted ? 1.0 : 0.4
            }
            buttonOK.performOnPressed = { _ in
                self.hiddeAnimated(completion: self.completion)
            }
            self.addSubview(buttonOK)
        case let .doubleButton(leftTitle, rightTitle, action):
            self.completion = action
            self.backgroundColor = colors.alertDoubleButtonBackground
            label.textColor = colors.alertDoubleButtonTitle
            let padding = label.frame.origin.x
            let buttonSize = CGSize(width: (screenSize.width - 3*padding)/2, height: buttonHeight)
            let buttonOriginY = self.frame.height - buttonHeight - buttonPaddingBottom
            let buttonCancel = Button()
            buttonCancel.frame.size = buttonSize
            buttonCancel.layer.masksToBounds = true
            buttonCancel.layer.cornerRadius = 5
            buttonCancel.frame.origin = CGPoint(x: padding, y: buttonOriginY)
            buttonCancel.backgroundColor = colors.alertDoubleButton_LeftButtonBackground
            buttonCancel.titleLabel?.font = CreateCardViewController.configuration.fonts.alertButtons
            buttonCancel.setTitle(leftTitle, for: .normal)
            buttonCancel.setTitleColor(colors.alertDoubleButton_LeftButtonTitle, for: .normal)
            buttonCancel.didChangeState = { _, state in
                buttonCancel.alpha = state == .highlighted ? 1.0 : 0.4
            }
            buttonCancel.performOnPressed = { _ in
                self.hiddeAnimated(completion: nil)
            }
            
            let buttonPaste = Button()
            buttonPaste.frame.size = buttonSize
            buttonPaste.layer.masksToBounds = true
            buttonPaste.layer.cornerRadius = 5
            buttonPaste.frame.origin = CGPoint(x: screenSize.width - padding - buttonSize.width, y: buttonOriginY)
            buttonPaste.backgroundColor = colors.alertDoubleButton_RightButtonBackground
            buttonPaste.titleLabel?.font = CreateCardViewController.configuration.fonts.alertButtons
            buttonPaste.setTitle(rightTitle, for: .normal)
            buttonPaste.setTitleColor(colors.alertDoubleButton_RightButtonTitle, for: .normal)
            buttonPaste.didChangeState = { _, state in
                buttonPaste.alpha = state == .highlighted ? 1.0 : 0.4
            }
            buttonPaste.performOnPressed = { _ in
                self.hiddeAnimated(completion: self.completion)
            }
            self.addSubview(buttonCancel)
            self.addSubview(buttonPaste)
        }
        
        if #available(iOS 10.0, *) {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:)))
            self.addGestureRecognizer(panGesture)
        }
        self.addSubview(label)
    }
    
    func hiddeAnimated(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y = -self.frame.height - 2
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
    
    func showAnimated(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.4, animations: {
            self.frame.origin.y = 0
        }, completion: { _ in
            completion?()
        })
    }
    
    @objc func onDrag(_ gesture: UIPanGestureRecognizer) {
        if #available(iOS 10.0, *) {
            switch gesture.state {
            case .began:
                let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: nil)
                animator.addAnimations {
                    self.frame.origin.y = -self.frame.height - 2
                }
                animator.addCompletion { (_) in
                    self.removeFromSuperview()
                }
                self.propertyAnimator = animator
            case .changed:
                guard let animator = self.propertyAnimator as? UIViewPropertyAnimator else { return }
                let translation = gesture.translation(in: self)
                let y = translation.y
                guard y < 0 else { return }
                let fraction = abs(y / (self.frame.height))
                animator.fractionComplete = fraction
            case .ended, .cancelled:
                guard let animator = self.propertyAnimator as? UIViewPropertyAnimator else { return }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            default:
                break
            }
        }
    }
    
}
