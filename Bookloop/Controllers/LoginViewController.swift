//
//  LoginViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveSwift
import SVProgressHUD

class LoginViewController: UIViewController, SignUpViewControllerDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let store = RemoteStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.backgroundColor = UIColor.white
        
        self.bindUserInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindUserInterface() {

        let validEmailSignal = self.emailTextField.reactive.continuousTextValues.map { $0!.characters.count > 0 }
        let validPasswordSignal = self.passwordTextField.reactive.continuousTextValues.map { $0!.characters.count > 0 }
        
        let loginButtonBinding: BindingTarget<Bool> = self.loginButton.reactive.isEnabled
        loginButtonBinding <~ validEmailSignal.combineLatest(with: validPasswordSignal).map { $0 && $1 }
    }
    
    // MARK: - UI Handling
    
    @IBAction func handleLoginButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Logging in...")
        store.login(email: "user@co.edu", password: "password").then { _ -> Void in
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "MenuSegue", sender: nil)
        }.catch { SVProgressHUD.showError(withStatus: $0.localizedDescription) }
    }

    @IBAction func handleSignUpButton(_ sender: Any) {
        self.performSegue(withIdentifier: "SignUpSegue", sender: nil)
    }
    
    func signUpSuccessful() {
        self.dismiss(animated: true, completion: nil)
        // TODO: - Email validation
    }
    
    // MARK: - Navigation

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SignUpSegue" {
            (segue.destination as! SignUpViewController).delegate = self
        }
    }
    

}
