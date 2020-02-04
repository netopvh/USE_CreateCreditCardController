//
//  CreateCardViewController.swift
//
//  Created by Claudio Madureira Silva Filho on 11/01/19.
//  Copyright © 2019 Claudio Madureira Silva Filho. All rights reserved.
//

import UIKit


public protocol CreateCardViewControllerDelegate {
    func didTapDone(_ viewController: CreateCardViewController, cardDetails: [String: String])
}

public enum Language {
    case pt
    case en
    
    var isPortuguese: Bool {
        return self == .pt
    }
}

let LOGIC: [String: String] = ["ELO": "^(636368|636369|438935|504175|451416|636297|5067[0-9]{2}|4576[0-9]{2}|4011[0-9]{2}|506699)[0-9]{6,}$",
                               "VISA": "^4[0-9]{6,}$",
                               "MASTERCARD": "^5[1-5][0-9]{5,}$",
                               "DINERSCLUB": "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$",
                               "DISCOVER": "^6(?:011|5[0-9]{2})[0-9]{3,}$",
                               "AURA": "^(6011|622|64|65)",
                               "AMERICANEXPRESS": "^3[47][0-9]{5,}$",
                               "VISAELECTRON": "^(4026|417500|4508|4844|491(3|7))",
                               "JCB": "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$",
                               "HIPERCARD": "^(38|60)",
                               "MAESTRO": "^(?:5[0678]\\d\\d|6304|6390|67\\d\\d)\\d{8,15}$",
                               "UNIONPAY": "^62[0-5]\\d{13,16}$"]

public class CreateCardViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var fieldNumber: CardTextField!
    @IBOutlet weak var fieldExpiration: CardTextField!
    @IBOutlet weak var fieldName: CardTextField!
    @IBOutlet weak var fieldCVV: CardTextField!
    @IBOutlet weak var fieldCPF: CardTextField!
    @IBOutlet weak var fieldBirthDate: CardTextField!
    @IBOutlet weak var imvCard: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imvChip: UIImageView!
    @IBOutlet weak var imvBrand: UIImageView!
    @IBOutlet weak var lblCardHolder: UILabel!
    @IBOutlet weak var lblExpires: UILabel!
    @IBOutlet weak var lblExpiresTop: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblCVV: UILabel!
    @IBOutlet weak var constBottom: NSLayoutConstraint!
    @IBOutlet weak var constHeightViewContent: NSLayoutConstraint!
    @IBOutlet weak var constTopBirthDate: NSLayoutConstraint!
    
    public var delegate: CreateCardViewControllerDelegate?
    public static var configuration: CreateCardConfiguration = .default
    public static var checkPasteboardAndHandle: (() -> Void) = { }
    
    var language: Language = .en
    var isShowing: CardSide = .front
    var imagesMapped: [(String, String)] = []
    var requiredFields: [String: Bool] = [:]
    
    var cardBrandLogic: [String: Any] = [:] {
        didSet {
            self.imagesMapped.removeAll()
            for (key, values) in self.cardBrandLogic {
                if let values = values as? [String] {
                    for value in values {
                        self.imagesMapped.append((value, key))
                    }
                } else if let value = values as? String {
                    self.imagesMapped.append((value, key))
                }
            }
            self.imagesMapped.sort(by: { $0.0.count > $1.0.count })
        }
    }
    
    lazy var buttonBottom: Button = {
        let colors = CreateCardViewController.configuration.colors
        let screenSize = UIScreen.main.bounds.size
        let button = Button()
        let isInfiniteScreen = screenSize.height > 736
        button.frame.size = CGSize(width: screenSize.width, height: isInfiniteScreen ? 65 : 50)
        button.setTitle(self.language.isPortuguese ? "Confirmar".uppercased() : "Done".uppercased(), for: .normal)
        button.titleLabel?.font = CreateCardViewController.configuration.fonts.buttonBottom
        button.backgroundColor = colors.buttonBottomBackground
        button.setTitleColor(colors.buttonBottomTitle, for: .normal)
        button.didChangeState = { button, state in
            button.alpha = state == .highlighted ? 0.4 : 1
        }
        button.performOnPressed = { _ in
            if self.fieldNumber.isFirstResponder {
                self.fieldExpiration.becomeFirstResponder()
            } else if self.fieldExpiration.isFirstResponder {
                self.fieldName.becomeFirstResponder()
            } else if self.fieldName.isFirstResponder {
                self.fieldCVV.becomeFirstResponder()
            } else if self.fieldCVV.isFirstResponder {
                if self.isRequiredCPF {
                    self.fieldCPF.becomeFirstResponder()
                } else if self.isRequiredBirthDate {
                    self.fieldBirthDate.becomeFirstResponder()
                } else {
                    self.verifyAndGo()
                }
            } else if self.fieldCPF.isFirstResponder {
                if self.isRequiredBirthDate {
                    self.fieldBirthDate.becomeFirstResponder()
                } else {
                    self.verifyAndGo()
                }
            } else {
                self.verifyAndGo()
            }
        }
        return button
    }()
    
    
    
    enum CardSide {
        case back
        case front
    }
    
    var isRequiredCPF: Bool {
        return self.requiredFields["CPF"] ?? false
    }
    
    var isRequiredBirthDate: Bool {
        return self.requiredFields["birthDate"] ?? false
    }
    
    public override var inputAccessoryView: UIView? {
        return self.buttonBottom
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public class func instance(language: Language,
                               backendSetup: [String: Any]? = nil) -> CreateCardViewController {
        let vc = CreateCardViewController.instance(
            language: language,
            cardBrandLogic: backendSetup?["cardBrandLogic"] as? [String: Any])
        if let requiredFields = backendSetup?["requiredFields"] as? [String: Bool] {
            vc.requiredFields = requiredFields
        }
        return vc
    }
    
    public class func instance(language: Language,
                               cardBrandLogic: [String: Any]? = nil) -> CreateCardViewController {
        let vc = CreateCardViewController(nibName: "CreateCardViewController", bundle: Bundle(for: CreateCardViewController.self))
        vc.language = language
        vc.cardBrandLogic = cardBrandLogic ?? LOGIC
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidHidde(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        
        CreateCardViewController.checkPasteboardAndHandle = {
            self.checkPasteboardAndHandle()
        }
        
        self.imvCard.image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: "map", type: "png")
        self.imvChip.image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: "chip", type: "png")
        self.viewCard.layer.masksToBounds = true
        self.viewCard.layer.cornerRadius = 6
        let isPortuguese = self.language.isPortuguese
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.hiddeKeyboard))
        self.fieldCVV.superview?.addGestureRecognizer(gesture)
        
        self.setTextField(
            textField: fieldBirthDate,
            placeholder: isPortuguese ? "Data de nascimento" : "Date of birth",
            mask: "##/##/####",
            keyboardType: .numberPad,
            nextField: nil,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: false)
        },
            didChangeText: { text in
                
        })
        
        self.setTextField(
            textField: fieldCPF,
            placeholder: "CPF",
            mask: "###.###.###-##",
            keyboardType: .numberPad,
            nextField: self.isRequiredBirthDate ? fieldBirthDate : nil,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: self.isRequiredBirthDate)
        },
            didChangeText: { text in
                
        })
        
        self.setTextField(
            textField: fieldCVV,
            placeholder: isPortuguese ? "Código" : "CVV",
            mask: "###",
            keyboardType: .numberPad,
            nextField: self.isRequiredCPF ? fieldCPF : self.isRequiredBirthDate ? fieldBirthDate : nil,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: self.isRequiredCPF || self.isRequiredBirthDate)
                self.animateCardImage(to: .back)
                let frame = self.fieldCVV.frame
                guard let superview = self.fieldCVV.superview,
                    self.scrollView.contentOffset.y > superview.frame.height - frame.origin.y - frame.height else { return }
                self.animateScrollView(to: 0)
        },
            didChangeText: { text in
                self.lblCVV.text = text
        })
        
        self.setTextField(
            textField: fieldName,
            placeholder: isPortuguese ? "Nome do titular" : "Owner's name",
            mask: nil,
            keyboardType: .default,
            nextField: fieldCVV,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: true)
                self.animateCardImage(to: .front)
                let frame = self.fieldCVV.frame
                guard let superview = self.fieldCVV.superview,
                    self.scrollView.contentOffset.y > superview.frame.height - frame.origin.y - frame.height else { return }
                self.animateScrollView(to: 0)
        },
            didChangeText: { text in
                self.lblName.text = text
        })
        
        self.setTextField(
            textField: fieldExpiration,
            placeholder: isPortuguese ? "MM/AA" : "MM/YY",
            mask: "##/##",
            keyboardType: .numberPad,
            nextField: fieldName,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: true)
                self.animateCardImage(to: .front)
                self.animateScrollView(to: 0)
        },
            didChangeText: { text in
                self.lblExpires.text = text
        })
        
        self.setTextField(
            textField: fieldNumber,
            placeholder: isPortuguese ? "Número do cartão" : "Card number",
            mask: "#### #### #### ####",
            keyboardType: .numberPad,
            nextField: fieldExpiration,
            shouldBeginEditing: {
                self.setButtonTitle(isNext: true)
                self.animateCardImage(to: .front)
                self.animateScrollView(to: 0)
        },
            didChangeText: { text in
                let text = text ?? ""
                self.imvBrand.image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: self.getCardImage(number: text) ?? "", type: ".png")?.resize(targetSize: self.imvBrand.frame.size)
                self.lblNumber.text = text
        })
        
        let labels = [self.lblCVV, self.lblName, self.lblNumber, self.lblExpires]
        labels.forEach({ lbl in
            lbl?.font = CreateCardViewController.configuration.fonts.labelCard
        })
        
        let _labels = [self.lblCardHolder, self.lblExpiresTop]
        _labels.forEach({ lbl in
            lbl?.font = CreateCardViewController.configuration.fonts.labelCardHolders
        })
        
        self.fieldCPF.isHidden = !self.isRequiredCPF
        self.fieldBirthDate.isHidden = !self.isRequiredBirthDate
        let isBothRequired = self.isRequiredBirthDate && self.isRequiredCPF
        let isOneRequired = self.isRequiredCPF || self.isRequiredBirthDate
        if !self.isRequiredCPF {
            self.constTopBirthDate.constant = -45
        }
        let height: CGFloat = UIScreen.main.bounds.width*0.87*210/322 + 20 + 3*50 + 17 + 45 + 20
        self.constHeightViewContent.constant = isOneRequired ? isBothRequired ? height : height - 50 : height - 100
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.checkPasteboardAndHandle()
        })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.becomeFirstResponder()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideAlertView()
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.view.endEditing(false)
        self.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
        super.dismiss(animated: flag, completion: completion)
    }
    
    // MARK: - Local Functions
    
    @objc func hiddeKeyboard() {
        self.setButtonTitle(isNext: false)
        if self.fieldNumber.isFirstResponder {
            self.fieldNumber.resignFirstResponder()
        } else if self.fieldExpiration.isFirstResponder {
            self.fieldExpiration.resignFirstResponder()
        } else if self.fieldName.isFirstResponder {
            self.fieldName.resignFirstResponder()
        } else if self.fieldCVV.isFirstResponder {
            self.fieldCVV.resignFirstResponder()
        } else if self.fieldCPF.isFirstResponder {
            self.fieldCPF.resignFirstResponder()
        } else {
            self.fieldBirthDate.resignFirstResponder()
        }
    }
    
    fileprivate func hideAlertView() {
        let view = self.navigationController?.view ?? self.view
        if let subviews = view?.subviews {
            for subview in subviews {
                if let alertView = subview as? AlertCreateCardView {
                    alertView.hiddeAnimated(completion: nil)
                }
            }
        }
    }
    
    func verifyAndGo() {
        self.hideAlertView()
        guard self.verifyAllFields() else { return }
        let number: String = self.fieldNumber.text!.replacingOccurrences(of: " ", with: "")
        var details: [String: String] = ["number": number,
                                         "name": self.fieldName.text!,
                                         "cvv": self.fieldCVV.text!,
                                         "expirationDate": self.fieldExpiration.text!.replacingOccurrences(of: "/", with: ""),
                                         "brand": self.getCardImage(number: number)?.lowercased() ?? ""]
        if self.isRequiredCPF {
            details.updateValue(self.fieldCPF.text!, forKey: "cpf")
        }
        if self.isRequiredBirthDate {
            details.updateValue(self.fieldBirthDate.text!, forKey: "birthDate")
        }
        self.delegate?.didTapDone(self, cardDetails: details)
    }
    
    func verifyAllFields() -> Bool {
        guard let number = self.fieldNumber.text?.replacingOccurrences(of: " ", with: ""),
            number.count == 4*4 else {
                let message: String = self.language.isPortuguese ? "O campo número do cartão deve ser preenchido corretamente." : "The card number field must filled correctly."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldNumber.becomeFirstResponder()
                })
                return false
        }
        guard let expirationDate = self.fieldExpiration.text,
            expirationDate.count == 5 else {
                let message: String = self.language.isPortuguese ? "O campo data de validade do cartão deve ser preenchido corretamente." : "The expiration date field must filled correctly."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldExpiration.becomeFirstResponder()
                })
                return false
        }
        
        guard self.verifyExpirationDate(string: expirationDate) else {
            let message: String = self.language.isPortuguese ? "Data de validade inválida" : "Invalid expiration date."
            self.showAlertSingleButton(message: message, handler: {
                self.fieldExpiration.becomeFirstResponder()
            })
            return false
        }
        guard let name = self.fieldName.text?.replacingOccurrences(of: " ", with: ""),
            name.count >= 3 else {
                let message: String = self.language.isPortuguese ? "O campo nome do propriestário do cartão deve ser preenchido corretamente." : "The card's owner name field must filled correctly."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldName.becomeFirstResponder()
                })
                return false
        }
        guard let cvv = self.fieldCVV.text,
            cvv.count == 3 else {
                let message: String = self.language.isPortuguese ? "O campo código de segurança do cartão deve ser preenchido corretamente." : "The card security code field must filled correctly."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldCVV.becomeFirstResponder()
                })
                return false
        }
        if self.isRequiredCPF {
            guard let cpf = self.fieldCPF.text?.replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: "-", with: ""),
                cpf.count == 11 else {
                    let message: String = self.language.isPortuguese ? "O campo CPF do cartão deve ser preenchido corretamente." : "The card owner's CPF field must filled correctly."
                    self.showAlertSingleButton(message: message, handler: {
                        self.fieldCPF.becomeFirstResponder()
                    })
                    return false
            }
            guard cpf.isValidCPF else {
                let message: String = self.language.isPortuguese ? "CPF inválido." : "Invalid CPF."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldCPF.becomeFirstResponder()
                })
                return false
            }
        }
        if self.isRequiredBirthDate {
            guard let birthDate = self.fieldBirthDate.text,
                birthDate.count == 10 else {
                    let message: String = self.language.isPortuguese ? "O campo data de nascimento do proprietário do cartão deve ser preenchido corretamente." : "The card owner's birth date field must be filled correctly."
                    self.showAlertSingleButton(message: message, handler: {
                        self.fieldBirthDate.becomeFirstResponder()
                    })
                    return false
            }
            guard self.verifyBirthDate(date: birthDate) else {
                let message: String = self.language.isPortuguese ? "Data de nascimento inválida." : "Invalid birth date."
                self.showAlertSingleButton(message: message, handler: {
                    self.fieldBirthDate.becomeFirstResponder()
                })
                return false
            }
        }
        return true
    }
    
    func showAlert(message: String, action: (() -> Void)?) {
        let cancel = self.language.isPortuguese ? "Não" : "No"
        let paste = self.language.isPortuguese ? "Colar" : "Paste"
        let type: AlertType = action == nil ? .noButton : .doubleButton(cancel, paste, action!)
        let view = self.navigationController?.view ?? self.view
        if let alert = view?.subviews.first(where: { $0 is AlertCreateCardView }) as? AlertCreateCardView,
            alert.type.isDoubleButtonType && type.isDoubleButtonType {
            alert.label.text = message
            alert.completion = action
            return
        }
        let alert = AlertCreateCardView.init(text: message, type: type)
        view?.addSubview(alert)
        alert.showAnimated(completion: {
            guard action == nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                guard alert.frame.origin.y == 0 else { return }
                alert.hiddeAnimated(completion: nil)
            })
        })
    }
    
    func verifyExpirationDate(string: String) -> Bool {
        let components = string.components(separatedBy: "/")
        let month = Int(components[0])!
        let year = Int("20" + components[1])!
        let isMonthOk = month > 0 && month <= 12
        let calendar = Calendar.current
        let now = Date()
        let thisYear = calendar.component(.year, from: now)
        let isYearOk = year >= thisYear
        if year == thisYear {
            let thisMonth = calendar.component(.month, from: now)
            return month >= thisMonth && month <= 12
        }
        return isMonthOk && isYearOk
    }
    
    func verifyBirthDate(date: String) -> Bool {
        let dateComp = date.components(separatedBy: "/")
        guard dateComp.count == 3,
            let day = Int(dateComp[self.language.isPortuguese ? 0 : 1]),
            let month = Int(dateComp[self.language.isPortuguese ? 1 : 0]),
            let year = Int(dateComp[2]) else { return false }
        let isDayOK = day <= 31 && day > 0
        let isMonthOK = month <= 12 && month > 0
        let calendar = Calendar.current
        let now = Date()
        let thisYear = calendar.component(.year, from: now)
        let isYearOK = year <= thisYear
        if year == thisYear {
            let thisMonth = calendar.component(.month, from: now)
            let today = calendar.component(.day, from: now)
            if month == thisMonth {
                return day <= today
            } else if month < thisMonth {
                return isDayOK
            } else {
                return false
            }
        }
        return isDayOK && isMonthOK && isYearOK
    }
    
    func setButtonTitle(isNext: Bool) {
        let title: String
        if isNext {
            title = self.language.isPortuguese ? "Avançar".uppercased() : "Next".uppercased()
        } else {
            title = self.language.isPortuguese ? "Confirmar".uppercased() : "Done".uppercased()
        }
        self.buttonBottom.setTitle(title, for: .normal)
    }
    
    
    func showAlertSingleButton(message: String, handler: @escaping (() -> Void)) {
        let view = self.navigationController?.view ?? self.view
        if let alert = view?.subviews.first(where: { $0 is AlertCreateCardView }) as? AlertCreateCardView {
            alert.label.text = message
            alert.completion = handler
            return
        }
        let alert = AlertCreateCardView.init(
            text: message,
            type: .singleButton("Ok", handler)
        )
        view?.addSubview(alert)
        alert.showAnimated(completion: nil)
    }
    
    func animateScrollView(field: UITextField) {
        guard let superview = field.superview else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset.y = superview.frame.height - field.frame.origin.y - field.frame.height
        })
    }
    
    func animateScrollView(to originY: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset.y = originY
        })
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
            UIView.animate(withDuration: 0.15, animations: {
                self.constBottom.constant = keyboardHeight
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardDidHidde(_ notification: Notification) {
        UIView.animate(withDuration: 0.15, animations: {
            self.constBottom.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func setTextField(textField: CardTextField,
                      placeholder: String,
                      mask: String?,
                      keyboardType: UIKeyboardType,
                      nextField: CardTextField?,
                      shouldBeginEditing: (() -> Void)?,
                      didChangeText: @escaping ((String?) -> Void)) {
        let colors = CreateCardViewController.configuration.colors
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 17),
                                                         NSAttributedString.Key.foregroundColor: colors.textFieldTint.withAlphaComponent(0.5)]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        textField.inputMask = mask ?? ""
        textField.nextField = nextField
        textField.shouldBeginEditing = shouldBeginEditing
        textField.didChangeText = didChangeText
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = colors.textFieldTint
        textField.font = CreateCardViewController.configuration.fonts.textField
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
    }
    
    func animateCardImage(to side: CardSide) {
        guard side != self.isShowing else { return }
        let duration: TimeInterval = 0.4
        UIView.transition(with: self.viewCard,
                          duration: duration,
                          options: side == .front ? .transitionFlipFromRight: .transitionFlipFromLeft,
                          animations: {
                            self.imvCard.image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: side == .front ? "map" : "cardback", type: "png")
                            let alphaFront: CGFloat = side == .front ? 1 : -1
                            self.lblExpires.alpha = alphaFront
                            self.lblName.alpha = alphaFront
                            self.lblNumber.alpha = alphaFront
                            self.imvBrand.alpha = alphaFront
                            self.imvChip.alpha = alphaFront
                            self.lblCardHolder.alpha = alphaFront
                            self.lblExpiresTop.alpha = alphaFront
                            self.lblCVV.alpha = -alphaFront
        }, completion: { _ in
            self.isShowing = side
        })
    }
    
    func getCardImage(number: String) -> String? {
        let cardNumber = number.replacingOccurrences(of: " ", with: "")
        for (key, value) in self.imagesMapped {
            if self.verifyIfItIsRegex(string: key) {
                if self.matchesRegex(regex: key, text: cardNumber) {
                    //                    let image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: value, type: ".png")?.resize(targetSize: self.imvBrand.frame.size)
                    //                    return image
                    return value
                }
            } else {
                if cardNumber.count >= key.count {
                    if cardNumber.subString(to: key.count) == key {
                        //                        let image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: value, type: ".png")?.resize(targetSize: self.imvBrand.frame.size)
                        //                        return image
                        return value
                    }
                }
            }
        }
        return nil
    }
    
    func verifyIfItIsRegex(string: String) -> Bool {
        let numbers = (0..<10).map({ return "\($0)"})
        for char in string {
            if !numbers.contains("\(char)") {
                return true
            }
        }
        return false
    }
    
    func matchesRegex(regex: String, text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let nsString = text as NSString
            let match = regex.firstMatch(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return (match != nil)
        } catch {
            return false
        }
    }
    
    
    // MARK: - UIPasteBoard Functions
    
    @objc func checkPasteboardAndHandle() {
        guard let text = UIPasteboard.general.string else { return }
        let onlyNumbers = self.getOnlyNumbers(text: text)
        if self.isCard(text: onlyNumbers) {
            let newCardNumber = self.getCardFormatted(numbers: onlyNumbers)
            let currentNumber = self.fieldNumber.text ?? ""
            guard currentNumber != newCardNumber else { return }
            if self.isCard(text: self.getOnlyNumbers(text: currentNumber)) {
                let message = self.language.isPortuguese ? "Deseja trocar o cartão por\n\(newCardNumber)?" : "Want to change the card number for \n\(newCardNumber)?"
                self.showAlert(message: message, action: {
                    self.setCardNumber(number: newCardNumber, showAlert: false)
                })
            } else {
                self.setCardNumber(number: newCardNumber, showAlert: true)
            }
        } else if self.isCPF(text: onlyNumbers) {
            let newCPF = self.getCPFFormatted(numbers: onlyNumbers)
            let currentCPF = self.fieldCPF.text ?? ""
            guard currentCPF != newCPF else { return }
            if self.isCPF(text: self.getOnlyNumbers(text: currentCPF)) {
                let message = self.language.isPortuguese ? "Deseja trocar o CPF por\n\(newCPF)?" : "Want to change the CPF for\n\(newCPF)?"
                self.showAlert(message: message, action: {
                    self.setCPF(number: newCPF, showAlert: false)
                })
            } else {
                self.setCPF(number: newCPF, showAlert: true)
            }
        }
    }
    
    func isCard(text: String) -> Bool {
        return text.count == 16
    }
    
    func isCPF(text: String) -> Bool {
        return text.count == 11 && text.isValidCPF
    }
    
    func getOnlyNumbers(text: String) -> String {
        var newString = ""
        let numbers: [String] = (0..<10).map({ return "\($0)" })
        for char in text {
            if numbers.contains("\(char)") {
                newString.append(char)
            }
        }
        return newString
    }
    
    func getCPFFormatted(numbers: String) -> String {
        var cpf = ""
        for (index, char) in numbers.enumerated() {
            switch index {
            case 3, 6:
                cpf.append(".\(char)")
            case 9:
                cpf.append("-\(char)")
            default:
                cpf.append(char)
            }
        }
        return cpf
    }
    
    func getCardFormatted(numbers: String) -> String {
        var cardNumber = ""
        for (index, char) in numbers.enumerated() {
            switch index {
            case 4,8,12:
                cardNumber.append(" \(char)")
            default:
                cardNumber.append("\(char)")
            }
        }
        return cardNumber
    }
    
    func setCardNumber(number: String, showAlert: Bool) {
        self.imvBrand.image = UIImage.getFrom(customClass: CreateCardViewController.self, nameResource: self.getCardImage(number: number) ?? "", type: ".png")?.resize(targetSize: self.imvBrand.frame.size)
        self.fieldNumber.text = number
        self.lblNumber.text = number
        guard showAlert else { return }
        let message = self.language.isPortuguese ? "Número do cartão copiado da área de transferência!" : "Card number copied from pasteboard!"
        self.showAlert(message: message, action: nil)
    }
    
    func setCPF(number: String, showAlert: Bool) {
        self.fieldCPF.text = number
        guard showAlert else { return }
        let message = self.language.isPortuguese ? "CPF copiado da área de transferência!" : "CPF copied from pasteboard!"
        self.showAlert(message: message, action: nil)
    }
    
    
}
