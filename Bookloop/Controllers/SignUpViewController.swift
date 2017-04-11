//
//  SignUpViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import SVProgressHUD

protocol SignUpViewControllerDelegate: class {
    func signUpSuccessful()
}

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    let store = RemoteStore()
    
    weak var delegate: SignUpViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUserInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindUserInterface() {
        
        // Text fields
        let validEmailSignal = self.emailTextField.reactive.continuousTextValues.map { $0!.characters.count > 0 }
        let validPasswordSignal = self.passwordTextField.reactive.continuousTextValues.map { $0!.characters.count > 0 }
        
        let signUpButtonBinding: BindingTarget<Bool> = self.signUpButton.reactive.isEnabled
        signUpButtonBinding <~ validEmailSignal.combineLatest(with: validPasswordSignal).map { $0 && $1 }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Signing up...")
        store.signUp(email: emailTextField.text!, password: passwordTextField.text!).then { _ -> Void in
            SVProgressHUD.dismiss()
            self.delegate?.signUpSuccessful()
        }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
    }
    
    @IBAction func handleCancelButton(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
