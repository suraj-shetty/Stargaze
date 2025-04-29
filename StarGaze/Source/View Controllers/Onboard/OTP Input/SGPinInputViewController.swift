//
//  SGPinInputViewController.swift
//  StarGaze
//
//  Created by Suraj Shetty on 14/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import SwiftDate
import RxSwift
import RxGesture

class SGPinInputViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: SGButton!
    @IBOutlet weak var pinField: SGPinView!
    @IBOutlet weak var resendLabel: UILabel!
    
    private var timer:Timer?
    private var expiryDate:Date?
    private var disposeBag = DisposeBag()
    
    unowned var viewModel:SGOnboardViewModel!
    unowned var router:SGOnboardRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configurePinInput()
        initRxBinding()
        triggerTimer()
//        DispatchQueue.main.async {[weak self] in
//
//        }
    }


    deinit {
        timer?.invalidate()
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

private extension SGPinInputViewController {
    func configurePinInput() {
        pinField.fillColor = .brand2.withAlphaComponent(0.18)
        pinField.textBackgroundColor = .brand2.withAlphaComponent(0.1)
        pinField.delegate = self
        pinField.clear()
    }
    
    func triggerTimer() {
        timer?.invalidate()
        
        expiryDate = Date.now + 2.minutes
        updateTimeInterval()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1,
                                     repeats: true, block: {[weak self] _ in
            self?.updateTimeInterval()
        })
//        timer?.tolerance = 0.3 //
        RunLoop.current.add(timer!, forMode: .common) //Run the timer, even if UI thread is blocked
        
        resendLabel.isUserInteractionEnabled = false //Block from resending the request, until the timer ends
    }
    
    func updateTimeInterval() {
        let current = Date.now
        if expiryDate == nil || current > expiryDate! {
            timer?.invalidate()
            timer = nil
            expiryDate = nil
            
            resendLabel.alpha = 1
            resendLabel.text = "Send me a new code"
            resendLabel.isUserInteractionEnabled = true
        }
        else {
            let format = (expiryDate! - current).timeInterval.rounded()
//            debugPrint(format)
            let string = format.toString {
                $0.maximumUnitCount = 2
                $0.allowedUnits = [.minute, .second]
                $0.collapsesLargestUnit = false
                $0.unitsStyle = .abbreviated
                $0.zeroFormattingBehavior = .dropAll
            }
            
            resendLabel.text = "Resend in \(string)"
            resendLabel.alpha = 0.5
        }
    }
}

private extension SGPinInputViewController {
    func initRxBinding() {
        backButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.navigateBack()
        })
        .disposed(by: disposeBag)
        
        submitButton.rx.tap.subscribe(onNext: {[weak self] in
            self?.submitPin()
        })
        .disposed(by: disposeBag)
        
        resendLabel.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.requestForPin()
            })
            .disposed(by: disposeBag)
    }
    
    func requestForPin() {
        SGAlertUtility.showHUD()
        viewModel.onboard {[weak self] didOnboard, error in
            SGAlertUtility.hidHUD()
            
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else {
                self?.triggerTimer()
            }
        }
    }
    
    func submitPin() {
        let pin = pinField.pin
        if pin.count < pinField.length {
            SGAlertUtility.showErrorAlert(message: "Invalid OTP entered")
            return
        }
        
        SGAlertUtility.showHUD()
        viewModel.authenticate(with: pin) {[weak self] user, error in
            SGAlertUtility.hidHUD()
            if let error = error {
                SGAlertUtility.showErrorAlert(message: error.localizedDescription)
            }
            else if let user = user {
                debugPrint("Received User")
//                if let dict = user.dictionary {
//                    debugPrint(dict)
//                }
                
                self?.enter(with: user)
            }
        }
    }
    
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}

private extension SGPinInputViewController {
    func enter(with user:UserDetail) {
        SGAppSession.shared.user.send(user)
        SGUserDefaultStorage.saveUserData(user: user)
        
        router.route(to: SGOnboardRouter.Route.home.rawValue,
                     from: self,
                     parameters: user)
    }
}

extension SGPinInputViewController: SGPinViewDelegate {
    func didEnterPin(view: SGPinView) {
//        debugPrint("Entered pin \(view.pin)")
        view.resignFirstResponder()
    }
}
