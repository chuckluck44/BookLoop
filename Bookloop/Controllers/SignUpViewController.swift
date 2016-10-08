//
//  SignUpViewController.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Rex
import SVProgressHUD

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    var viewModel: SignUpViewModel

    required init?(coder aDecoder: NSCoder) {
        self.viewModel = SignUpViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bindViewModel() {
        
        // Test fields
        self.viewModel.email <~ self.emailTextField.rac_textSignal().toSignalProducer()
            .ignoreError()
            .map { $0 as! String }
        self.viewModel.password <~ self.passwordTextField.rac_textSignal().toSignalProducer()
            .ignoreError()
            .map { $0 as! String }
        
        // Sign Up Action
        self.signUpButton.rex_pressed.value = self.viewModel.signUpAction.unsafeCocoaAction
        
        // Navigation
        self.viewModel.isSignedUp
            .producer
            .startWithNext {[unowned self] in
                if $0 {self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)}
            }
        
        // Progress alerts
        self.viewModel.alertMessageSignal
            .observeNext { type in SVProgressHUD.show(type) }
    }
    
    @IBAction func handleCancelButton(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
