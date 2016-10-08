//
//  LoginViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Rex
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.loginButton.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindViewModel() {
        
        // Text fields
        self.viewModel.email <~ self.emailTextField.rac_textSignal().toSignalProducer()
            .ignoreError()
            .map { text in text as! String }
        self.viewModel.password <~ self.passwordTextField.rac_textSignal().toSignalProducer()
            .ignoreError()
            .map { text in text as! String }
        
        // Login Action
        self.loginButton.rex_pressed.value = self.viewModel.loginAction.unsafeCocoaAction
        
        // Navigation
        self.viewModel.isLoggedIn
            .producer
            .startWithNext { [weak self] succeeded in if succeeded {self!.performSegueWithIdentifier("MenuSegue", sender: nil)} }
        
        // Progress alerts
        self.viewModel.alertMessageSignal
            .observeNext { type in
                SVProgressHUD.show(type)
            }
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
