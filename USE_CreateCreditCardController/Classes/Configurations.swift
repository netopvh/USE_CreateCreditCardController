//
//  Configurations.swift
//
//  Created by Claudio Madureira Silva Filho on 16/01/19.
//

import UIKit

public class CreateCardConfiguration {
    
    var colors: CreateCardConfigurationColors
    var fonts: CreateCardConfigurationFonts
    
    public static var `default`: CreateCardConfiguration {
        return CreateCardConfiguration.init(fonts: .default, colors: .default)
    }
    
    init(fonts: CreateCardConfigurationFonts,
         colors: CreateCardConfigurationColors) {
        self.fonts = fonts
        self.colors = colors
    }
}


// MARK: - Colors

public class CreateCardConfigurationColors {
    public var textFieldTint: UIColor
    public var buttonBottomBackground: UIColor
    public var buttonBottomTitle: UIColor
    public var alertShadow: UIColor
    public var alertNoButtonBackground: UIColor
    public var alertNoButtonTitle: UIColor
    public var alertSingleButtonBackground: UIColor
    public var alertSingleButtonTitle: UIColor
    public var alertDoubleButtonBackground: UIColor
    public var alertDoubleButtonTitle: UIColor
    
    // DoubleButtonAlert
    public var alertDoubleButton_LeftButtonBackground: UIColor
    public var alertDoubleButton_LeftButtonTitle: UIColor
    public var alertDoubleButton_RightButtonBackground: UIColor
    public var alertDoubleButton_RightButtonTitle: UIColor
    
    // SingleButtonAlert
    public var alertSingleButton_ButtonBackground: UIColor
    public var alertSingleButton_ButtonTitle: UIColor
    
    public static var `default`: CreateCardConfigurationColors {
        return CreateCardConfigurationColors.init(textFieldTint: .black,
                                                  buttonBottomBackground: .black,
                                                  buttonBottomTitle: .white,
                                                  alertShadow: .black,
                                                  alertNoButtonBackground: UIColor(red: 105/255, green: 176/255, blue: 145/255, alpha: 1),
                                                  alertNoButtonTitle: .white,
                                                  alertSingleButtonBackground: UIColor(red: 193/255, green: 47/255, blue: 61/255, alpha: 1),
                                                  alertSingleButtonTitle: .white,
                                                  alertDoubleButtonBackground: UIColor(red: 105/255, green: 176/255, blue: 145/255, alpha: 1),
                                                  alertDoubleButtonTitle: .white,
                                                  alertDoubleButton_LeftButtonBackground: UIColor(red: 193/255, green: 47/255, blue: 61/255, alpha: 1),
                                                  alertDoubleButton_LeftButtonTitle: .white,
                                                  alertDoubleButton_RightButtonBackground: UIColor(red: 52/255, green: 119/255, blue: 186/255, alpha: 1),
                                                  alertDoubleButton_RightButtonTitle: .white,
                                                  alertSingleButton_ButtonBackground: .white,
                                                  alertSingleButton_ButtonTitle: UIColor(red: 193/255, green: 47/255, blue: 61/255, alpha: 1))
    }
    
    init(textFieldTint: UIColor,
         buttonBottomBackground: UIColor,
         buttonBottomTitle: UIColor,
         alertShadow: UIColor,
         alertNoButtonBackground: UIColor,
         alertNoButtonTitle: UIColor,
         alertSingleButtonBackground: UIColor,
         alertSingleButtonTitle: UIColor,
         alertDoubleButtonBackground: UIColor,
         alertDoubleButtonTitle: UIColor,
         alertDoubleButton_LeftButtonBackground: UIColor,
         alertDoubleButton_LeftButtonTitle: UIColor,
         alertDoubleButton_RightButtonBackground: UIColor,
         alertDoubleButton_RightButtonTitle: UIColor,
         alertSingleButton_ButtonBackground: UIColor,
         alertSingleButton_ButtonTitle: UIColor) {
        
        self.textFieldTint = textFieldTint
        self.buttonBottomBackground = buttonBottomBackground
        self.buttonBottomTitle = buttonBottomTitle
        self.alertShadow = alertShadow
        self.alertNoButtonBackground = alertNoButtonBackground
        self.alertNoButtonTitle = alertNoButtonTitle
        self.alertSingleButtonBackground = alertSingleButtonBackground
        self.alertSingleButtonTitle = alertSingleButtonTitle
        self.alertDoubleButtonBackground = alertDoubleButtonBackground
        self.alertDoubleButtonTitle = alertDoubleButtonTitle
        self.alertDoubleButton_LeftButtonBackground = alertDoubleButton_LeftButtonBackground
        self.alertDoubleButton_LeftButtonTitle = alertDoubleButton_LeftButtonTitle
        self.alertDoubleButton_RightButtonBackground = alertDoubleButton_RightButtonBackground
        self.alertDoubleButton_RightButtonTitle = alertDoubleButton_RightButtonTitle
        self.alertSingleButton_ButtonBackground = alertSingleButton_ButtonBackground
        self.alertSingleButton_ButtonTitle = alertSingleButton_ButtonTitle
    }
}

// MARK: - Fonts

public class CreateCardConfigurationFonts {
    public var textField: UIFont
    public var labelCard: UIFont
    public var labelCardHolders: UIFont
    public var buttonBottom: UIFont
    public var alertTitle: UIFont
    public var alertButtons: UIFont
    
    public static var `default`: CreateCardConfigurationFonts {
        return CreateCardConfigurationFonts.init(textField: UIFont.systemFont(ofSize: 17, weight: .regular),
                                                 labelCard:  UIFont.systemFont(ofSize: 17, weight: .regular),
                                                 labelCardHolders: UIFont.systemFont(ofSize: 7, weight: .regular),
                                                 buttonBottom: UIFont.systemFont(ofSize: 18, weight: .semibold),
                                                 alertTitle: UIFont.systemFont(ofSize: 18, weight: .semibold),
                                                 alertButtons: UIFont.systemFont(ofSize: 18, weight: .bold))
    }
    
    init(textField: UIFont,
         labelCard: UIFont,
         labelCardHolders: UIFont,
         buttonBottom: UIFont,
         alertTitle: UIFont,
         alertButtons: UIFont) {
        self.textField = textField
        self.labelCard = labelCard
        self.labelCardHolders = labelCardHolders
        self.buttonBottom = buttonBottom
        self.alertTitle = alertTitle
        self.alertButtons = alertButtons
    }
}
