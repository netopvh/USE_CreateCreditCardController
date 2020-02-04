//
//  CardTextField.swift
//  Rotation
//
//  Created by Claudio Madureira Silva Filho on 07/01/19.
//  Copyright © 2019 Claudio Madureira Silva Filho. All rights reserved.
//

import UIKit

class CardTextField: UITextField, UITextFieldDelegate {
    
    var changeAutomatically: Bool = true
    var inputMask: String = ""
    var nextField: CardTextField?
    var shouldBeginEditing: (() -> Void)?
    var didChangeText: ((String?) -> Void)?

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.delegate = self
        self.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        let line = UIView()
        line.backgroundColor = self.textColor?.withAlphaComponent(0.6)
        line.frame.size = CGSize(width: rect.width, height: 1)
        line.frame.origin.y = rect.height - 1
        self.addSubview(line)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.didChangeText?(textField.text)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.shouldBeginEditing?()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return nextField?.becomeFirstResponder() ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !inputMask.isEmpty else { return true }
        let newString0 = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        guard newString0.count <= self.inputMask.count else { return false }
        let newString1 = self.clearFormatCoponents(string: newString0)
        let newString = self.getNumberFormatted(number: newString1)
        self.setTextWithoutChangingRange(old: range, newString: newString, replacementString: string)
        self.didChangeText?(newString)
        if newString.count == inputMask.count && changeAutomatically {
            nextField?.becomeFirstResponder()
        }
        return false
    }
    
    private func isNumber(_ char: Character) -> Bool {
        return (0..<10).map({ return "\($0)" }).contains("\(char)")
    }
    
    func clearFormatCoponents(string: String) -> String {
        var newString = ""
        string.compactMap({Int(String($0))}).forEach({ newString.append("\($0)") })
        return newString
    }
    
    func getNumberFormatted(number: String) -> String {
        var returnText = ""
        var i = 0
        let maskArray = Array(inputMask)
        for char in number {
            let currCharMask = maskArray[i]
            if currCharMask == "#" {
                returnText.append(char)
            } else {
                returnText.append("\(currCharMask)\(char)")
                i += 1
            }
            i += 1
        }
        return returnText
    }
    
    func setTextWithoutChangingRange(old range: NSRange, newString: String, replacementString string: String) {
        if range.location != (self.text ?? "").count,
            let oldRange = self.selectedTextRange {
            let isUp = string != ""
            if range.length > 1 && !isUp {
                UIPasteboard.general.string = self.text?[range]
            }
            self.text = newString
            if let position = self.position(from: oldRange.start, offset: isUp ? 1 : range.length > 1 ? 0 : -1) {
                self.selectedTextRange = self.textRange(from: position, to: position)
            } else {
                self.selectedTextRange = self.textRange(from: oldRange.start, to: oldRange.start)
            }
        } else {
            self.text = newString
        }
    }
    
}

extension String {
    subscript(_ range: NSRange) -> String? {
        var substring = ""
        guard range.location + range.length - 1 < self.count else { return nil }
        let string = Array(self)
        for i in range.location..<(range.location + range.length) {
            substring.append(string[i])
        }
        return substring
    }
}
