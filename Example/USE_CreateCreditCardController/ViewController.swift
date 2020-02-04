//
//  ViewController.swift
//  USE_CreateCreditCardController
//
//  Created by Claudio Madureira on 01/14/2019.
//  Copyright (c) 2019 Claudio Madureira. All rights reserved.
//

import UIKit

import USE_CreateCreditCardController

typealias JSON = [String: Any]

class ViewController: UIViewController, CreateCardViewControllerDelegate {

    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblExpiration: UILabel!
    @IBOutlet weak var lblCVV: UILabel!
    
    @IBAction func btnAddCardPressed(_ sender: UIButton) {
        /*
         
         For changing colors and fonts. You can set this up in AppDelegate at didLaunchWithOptions function.
         
         let config = CreateCardConfiguration.default
         config.colors.alertNoButtonBackgroundColor = .black
         CreateCardViewController.configuration = config
         
         
         Also, do not forget to set up the `checkPasteboardAndHandle` static function from CreateCardViewController
         properly at AppDelegate, you can find how to do it in this demo.
         
         */
        
        let cardJSON = ["ELO": "^(636368|636369|438935|504175|451416|636297|5067[0-9]{2}|4576[0-9]{2}|4011[0-9]{2}|506699)[0-9]{6,}$",
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
                        "UNIONPAY": "^62[0-5]\\d{13,16}$"] as JSON
        let fullSetupJSON = ["requiredFields": ["CPF": true,
                                                "birthDate": true],
                             "cardBrandLogic": cardJSON] as JSON
        let vc = CreateCardViewController.instance(language: .pt, backendSetup: fullSetupJSON)
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - CreateCardViewControllerDelegate
    
    func didTapDone(_ viewController: CreateCardViewController, cardDetails: [String : String]) {
        print(cardDetails)
        self.lblNumber.text = "Number: \(cardDetails["number"] ?? "")"
        self.lblOwner.text = "Owner: \(cardDetails["name"] ?? "")"
        self.lblExpiration.text = "Expiration: \(cardDetails["expirationDate"] ?? "")"
        self.lblCVV.text = "CVV: \(cardDetails["cvv"] ?? "")"
        viewController.dismiss(animated: true, completion: nil)
    }
}

