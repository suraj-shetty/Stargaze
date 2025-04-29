//
//  SGPhoneInputViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 13/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import CountryKit
import RxSwift
import RxGesture
import PhoneNumberKit
import SafariServices

class SGPhoneInputViewController: UIViewController {
    unowned var router:SGOnboardRouter!
    
    @IBOutlet weak var pickerContentView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pickerCloseButton: UIButton!
    @IBOutlet weak var submitButton: SGButton!
    
    @IBOutlet weak var countryInfoView: UIStackView!
    @IBOutlet weak var countryIconView: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var countryPicker: UIPickerView!
    
    @IBOutlet weak var termsCheckbox: CheckBox!
    @IBOutlet weak var termsLabel: SGLinkLabel!
    
    private let countryKit = CountryKit()
    private let phoneKit = PhoneNumberKit()
    private var currentCountry:Country?
    private var disposeBag = DisposeBag()
    private let viewModel = SGOnboardViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupPicker()
        hidePicker()
        initRxBinding()        
        updateTermsAppearance()
        
        #if DEBUG
        if let ind = countryKit.searchByIsoCode("IN") {
            updateCountryInfo(with: ind)
            phoneTextField.text = "9740938617"
        }
        #else
        if let country = countryKit.current {
            updateCountryInfo(with: country)
        }
        #endif
        
        phoneTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK: - Coutry Picker
private extension SGPhoneInputViewController {
    func setupPicker() {
        countryPicker.backgroundColor = .brand1
        countryPicker.dataSource = self
        countryPicker.delegate = self
    }
    
    func hidePicker(_ animated:Bool = false) {
        if animated == false {
//            pickerContentView.transform = .init(translationX: 0, y: pickerContentView.frame.height)
            pickerContentView.isHidden = true
        }
        else {
            countryInfoView.isUserInteractionEnabled = false
            pickerContentView.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .curveEaseOut) {[weak self] in
                self?.pickerContentView.transform = .identity
            } completion: {[weak self] _ in
                self?.countryInfoView.isUserInteractionEnabled = true
                self?.pickerContentView.isUserInteractionEnabled = true
                self?.pickerContentView.isHidden = true
            }
        }
    }
    
    func showPicker() {
        countryInfoView.isUserInteractionEnabled = false
        pickerContentView.isHidden = false
        pickerContentView.transform = .init(translationX: 0, y: pickerContentView.frame.height)
        pickerContentView.isUserInteractionEnabled = false
                
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseOut) {[weak self] in
            self?.pickerContentView.transform = .identity
        } completion: {[weak self] _ in
            self?.countryInfoView.isUserInteractionEnabled = true
            self?.pickerContentView.isUserInteractionEnabled = true
        }
    }
}

//MARK: - RXBinding
private extension SGPhoneInputViewController {
    func initRxBinding() {
        backButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.navigateBack()
        })
        .disposed(by: disposeBag)

        submitButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.validateAndSubmitInput()
        })
        .disposed(by: disposeBag)
        
        countryInfoView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.changeRegion()
            })
            .disposed(by: disposeBag)
        
        pickerCloseButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.hidePicker(true)
        })
        .disposed(by: disposeBag)
        
        view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.phoneTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func requestOTP() {
        router.route(to: SGOnboardRouter.Route.otp.rawValue,
                     from: self,
                     parameters: viewModel)
    }
    
    func changeRegion() {
        phoneTextField.resignFirstResponder()
        showPicker()
    }
}

//MARK: - Terms
private extension SGPhoneInputViewController {
    func updateTermsAppearance() {
        termsCheckbox.style = .tick
        termsCheckbox.borderStyle = .rounded
        termsCheckbox.isChecked = false
        termsCheckbox.addTarget(self,
                                action: #selector(onCheckBoxValueChange(_:)),
                                for: .valueChanged)
        
        submitButton.isEnabled = false
        
        let termsText = NSLocalizedString("onboard.phone-input.terms", comment: "")
        let conditionHighlight = NSLocalizedString("onboard.highlight.terms", comment: "")
        let policyHighlight = NSLocalizedString("onboard.highlight.policy", comment: "")
        
        let conditionTextRange = (termsText as NSString).range(of: conditionHighlight)
        let policyTextRange = (termsText as NSString).range(of: policyHighlight)
        
        let attribText = NSMutableAttributedString(string: termsText)
    
        if conditionTextRange.location != NSNotFound {
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .attachment : URL(string: "open://condition")!,
                .foregroundColor: UIColor.brand2,
                .underlineColor: UIColor.brand2,
                //                .underlineStyle : NSUnderlineStyle.single.rawValue
            ]
            
            attribText.addAttributes(linkAttributes, range: conditionTextRange)
        }
        
        if policyTextRange.location != NSNotFound {
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .attachment : URL(string: "open://policy")!,
                .foregroundColor: UIColor.brand2,
                .underlineColor: UIColor.brand2,
                //                .underlineStyle : NSUnderlineStyle.single.rawValue
            ]
            
            attribText.addAttributes(linkAttributes, range: policyTextRange)
        }
        
        termsLabel.attributedText = attribText
        termsLabel.tintColor = .brand2
        termsLabel.backgroundColor = .brand1
        termsLabel.linkClickCallback = {[weak self] url in
            guard let self = self else { return }
            
            switch url.absoluteString {
            case "open://condition": self.loadWebView(with: URL(string: "https://stargaze.ai/terms-and-conditions")!)
            case "open://policy": self.loadWebView(with: URL(string: "https://stargaze.ai/privacy-policy")!)
                
            default: break
            }
        }
    }
    
    @objc func onCheckBoxValueChange(_ sender: CheckBox) {
        submitButton.isEnabled = sender.isChecked
        
        sender.checkboxBackgroundColor = sender.isChecked ? .brand2 : .clear
        sender.setNeedsDisplay()
    }
    
    func loadWebView(with url: URL) {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false
        
        let viewController = SFSafariViewController(url: url,
                                                    configuration: configuration)
        viewController.delegate = self
        viewController.dismissButtonStyle = .close
        viewController.preferredBarTintColor = .brand1
        viewController.preferredControlTintColor = .text1
        viewController.modalPresentationStyle = .fullScreen
        
        self.present(viewController, animated: true)
    }
}

extension SGPhoneInputViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, excludedActivityTypesFor URL: URL, title: String?) -> [UIActivity.ActivityType] {
        var excluded: [UIActivity.ActivityType] = [.postToFacebook,
                                                   .postToTwitter,
                                                   .postToWeibo,
                                                   .message,
                                                   .mail,
                                                   .print,
                                                   .copyToPasteboard,
                                                   .assignToContact,
                                                   .saveToCameraRoll,
                                                   .addToReadingList,
                                                   .postToFlickr,
                                                   .postToVimeo,
                                                   .postToTencentWeibo,
                                                   .airDrop,
                                                   .openInIBooks,
                                                   .markupAsPDF
        ]
        
        if #available(iOS 15.4, *) {
            excluded.append(.sharePlay)
        } else {
            // Fallback on earlier versions
        }
        
        return excluded
    }
}

//MARK: -
private extension SGPhoneInputViewController {
    func updateCountryInfo(with country:Country) {
        self.currentCountry = country
        
        countryIconView.image = country.flagImage
        if let phoneCode = country.phoneCode {
            countryCodeLabel.text = "+\(phoneCode)"
        }
        else {
            countryCodeLabel.text = ""
        }
    }
}

private extension SGPhoneInputViewController {
    func validateAndSubmitInput() {
        guard let countryCode = currentCountry?.phoneCode, let phoneNumber = phoneTextField.text
        else {
            return
        }
        
        let internationalNumber = "\(countryCode)\(phoneNumber)"
        do {
            _ = try phoneKit.parse(internationalNumber) //Validating phone number
        }
        catch {
            SGAlertUtility.showErrorAlert(message: "Invalid/Empty Mobile number. Please check your input")
            return
        }
        
        submit("\(phoneNumber)", code: "\(countryCode)")
    }
    
    func submit(_ number:String, code:String) {
        viewModel.phoneNumber = number
        viewModel.countryCode = code
        
        SGAlertUtility.showHUD()
        viewModel.onboard {[weak self] didOnboard, error in
            SGAlertUtility.hidHUD()
            
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else {
                self?.requestOTP()
            }
        }
    }
}

extension SGPhoneInputViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryKit.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let country = countryKit.countries[row]
        var subStrings = [String]()
        
        if let code = country.phoneCode {
            subStrings.append("+\(code)")
        }
        subStrings.append(country.localizedName)
        
        let text = subStrings.joined(separator: " ")
        let attributedText = NSAttributedString(string: text,
                                                attributes: [.foregroundColor : UIColor.text1])
        return attributedText
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let picked = countryKit.countries[row]
        updateCountryInfo(with: picked)
    }
}

extension SGPhoneInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let finalText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if finalText.count == 10 {
            textField.resignFirstResponder()
        }
        
        textField.text = finalText
        
        return false
    }
}
