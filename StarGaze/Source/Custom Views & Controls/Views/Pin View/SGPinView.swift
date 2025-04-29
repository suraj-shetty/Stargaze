//
//  SGPinView.swift
//  StarGaze
//
//  Created by Suraj Shetty on 14/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit


@objc protocol SGPinViewDelegate: NSObjectProtocol {
    func didEnterPin(view: SGPinView)
}


class SGOTPTextField: UITextField {

    weak var textFieldPrevious: SGOTPTextField?
    weak var textFieldNext: SGOTPTextField?
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



@IBDesignable
class SGPinView: UIControl {

    @IBInspectable var length: Int = 4 {
        didSet {
            setupInputFields()
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var spacing:CGFloat = 5.0 {
        didSet {
            stackView.spacing = spacing
        }
    }
    
    @IBInspectable var textColor: UIColor = .white {
        didSet {
            if let textFields = stackView.arrangedSubviews.filter({ $0 is UITextField}) as? [UITextField] {
                for item in textFields {
                    item.textColor = textColor
                    item.tintColor = textColor
                }
            }
        }
    }
    
    @IBInspectable var fillColor: UIColor = .clear {
        didSet {
            updateTextFieldAppearance()
        }
    }
    
    @IBInspectable var textBackgroundColor: UIColor = .clear {
        didSet {
            updateTextFieldAppearance()
        }
    }
    
    
    
    @IBInspectable var itemSize:CGSize = CGSize(width: 40, height: 40) {
        didSet {
            for item in stackView.arrangedSubviews {
                let currentConstraints = item.constraints
                item.removeConstraints(currentConstraints)
                
                item.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
                item.heightAnchor.constraint(equalToConstant: itemSize.height).isActive = true
            }
            
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            for item in stackView.arrangedSubviews {
                item.layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            for item in stackView.arrangedSubviews {
                item.layer.borderWidth = borderWidth
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            for item in stackView.arrangedSubviews {
                item.layer.cornerRadius = cornerRadius
            }
        }
    }
    
    @IBInspectable var isSecureEntry:Bool = false {
        didSet {
            
            let textFields = stackView.arrangedSubviews as! [UITextField]
            for field in textFields {
                field.isSecureTextEntry = isSecureEntry
            }
        }
    }
    
    var pin:String {
        get {
            let textComponents = (stackView.arrangedSubviews.map({ ($0 as! UITextField).text ?? ""}))
            let text = textComponents.joined()
            return text
        }
    }
    
    var font:UIFont = UIFont.boldSystemFont(ofSize: 30.0) {
        didSet {
            (stackView.arrangedSubviews as? [UITextField])?.forEach({
                $0.font = font
            })
        }
    }
    
    weak var delegate:SGPinViewDelegate? = nil
        
    private let stackView = UIStackView()
    
    
    //MARK:-
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupGestures()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
//        setupStackView()
        commonInit()
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return stackView.bounds.size
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        stackView.setNeedsLayout()
//    }
    
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false
        
        if stackView.superview != self {
            addSubview(stackView)
        }
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func setupInputFields() {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for i in 0..<length {
            let textField = SGOTPTextField()
            textField.textColor = textColor
            textField.font = UIFont.boldSystemFont(ofSize: 30.0)
            textField.textAlignment = .center
            textField.tintColor = textColor
//            textField.isEnabled = false
            textField.keyboardType = .numberPad
            textField.textContentType = .oneTimeCode
            textField.delegate = self
            textField.backgroundColor = fillColor
            textField.isSecureTextEntry = isSecureEntry
            textField.text = ""
            textField.tag = i
            let textFieldLayer = textField.layer
            textFieldLayer.borderColor = borderColor.cgColor
            textFieldLayer.borderWidth = 0
            textFieldLayer.cornerRadius = cornerRadius
            
            textField.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
            textField.heightAnchor.constraint(equalToConstant: itemSize.height).isActive = true
//            textField.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.addArrangedSubview(textField)
        }
        
        let textFields = stackView.arrangedSubviews.map({ $0 as! SGOTPTextField })
        textFields.enumerated().forEach { (i, field) in
            i != 0 ? (field.textFieldPrevious = textFields[i-1]) : ()
            i != 0 ? (textFields[i-1].textFieldNext = textFields[i]) : ()
        }
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ tapGesture:UITapGestureRecognizer) {
        _ = becomeFirstResponder()
    }
    
    private func commonInit() {
        setupStackView()
        setupInputFields()
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    override func becomeFirstResponder() -> Bool {
//        clear()
        
        let pinLength = max(pin.count, 1)
        let textFields = stackView.arrangedSubviews.map({ $0 as! UITextField})
        return textFields[pinLength-1].becomeFirstResponder()
    }
    
    private func updateTextFieldAppearance() {
        let textFields = stackView.arrangedSubviews.map({ $0 as! SGOTPTextField })
        var currentField: SGOTPTextField? = textFields.first

        while currentField != nil {
            currentField?.layer.borderWidth = (currentField?.isFirstResponder == true) ? borderWidth : 0.0
            currentField?.backgroundColor = (currentField?.text?.isEmpty == false) ? textBackgroundColor : fillColor
            currentField = currentField?.textFieldNext
        }
    }
    
    private func insertPin(_ pin:String) {
        let textFields = stackView.arrangedSubviews.map({ $0 as! UITextField })
        let pinLength = pin.count
        
        for i in 0..<pinLength {
            let index = pin.index(pin.startIndex, offsetBy: i)
            let charText = String(pin[index])
            textFields[i].text = charText
        }
        
        for i in pinLength..<length {
            textFields[i].text = ""
        }
        updateTextFieldAppearance()
    }
    
    func clear() {
        insertPin("")
    }
}

extension SGPinView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == length {
            insertPin(string)
            textField.resignFirstResponder()
            sendActions(for: .editingChanged)
            delegate?.didEnterPin(view: self)
            return false
        }
                        
        guard let pinField = textField as? SGOTPTextField
        else { return true }

        pinField.text = string

        if string.isEmpty == false {
            if pinField.tag == length-1 {
                pinField.resignFirstResponder()
                delegate?.didEnterPin(view: self)
            }
            else {
                pinField.textFieldNext?.becomeFirstResponder()
            }
        }
                
        sendActions(for: .editingChanged)
        sendActions(for: .valueChanged)
        return false
        
        
//        let textFields = stackView.arrangedSubviews.map({ $0 as! UITextField })
//        guard let index = textFields.firstIndex(of: textField)
//            else { return true }
//
//
//
//
//
//
//        if string == "" { //Deleting
//            (textField as? SGOTPTextField)?.textFieldPrevious?.becomeFirstResponder()
//        }
//        else { //
//            if index < length - 1 {
//                (textField as? SGOTPTextField)?.textFieldNext?.becomeFirstResponder()
//            }
//            else {
//                textField.resignFirstResponder()
//                delegate?.didEnterPin(view: self)
//            }
//        }
//        textField.text = string
//        updateTextFieldAppearance()
//        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let sgField = textField as? SGOTPTextField {
            sgField.layer.borderWidth = borderWidth
            sgField.backgroundColor = (sgField.text?.isEmpty == false) ? textBackgroundColor : fillColor
//            sgField.textFieldPrevious?.layer.borderWidth = 0
//            sgField.textFieldNext?.layer.borderWidth = 0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let sgField = textField as? SGOTPTextField {
            sgField.layer.borderWidth = 0
            sgField.backgroundColor = (sgField.text?.isEmpty == false) ? textBackgroundColor : fillColor
//            sgField.textFieldPrevious?.layer.borderWidth = 0
//            sgField.textFieldNext?.layer.borderWidth = 0
        }
    }
    
}
