//
//  OTPTextField.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import UIKit

class OTPTextField: UITextField {

    var textFieldPrevious: UITextField?
    var textFieldNext: UITextField?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func deleteBackward() {
        text = ""
        textFieldPrevious?.becomeFirstResponder()
    }

}
