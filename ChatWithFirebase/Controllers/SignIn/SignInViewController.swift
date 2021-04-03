//
//  ViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import FirebaseAuth
class SignInViewController: UIViewController {
    
    @IBOutlet weak var LoginBTN: UIButton!
    @IBOutlet weak var PassWordTXT: UITextField!
    @IBOutlet weak var EmailTXT: UITextField!
    override func viewDidLoad() {
        UserDefaults.standard.set(false, forKey: "Login")
        super.viewDidLoad()
        LoginBTN.layer.cornerRadius = 10
    }
    @IBAction func LoginClicked(_ sender: UIButton) {
        guard let email = EmailTXT.text ,EmailTXT.text != "" else {
            Errorpopup(message: "Fill Email Field")
            return
        }
        guard  let pass = PassWordTXT.text ,PassWordTXT.text != "" else {
            Errorpopup(message: "Fill Password Field")
            return
        }
        guard email.isValidEmail else {
            Errorpopup(message: "Enter Valid Email")
            return
        }
        Auth.auth().signIn(withEmail: email.lowercased(), password: pass) { (res, err) in
            //Error Checking
            if err != nil{
                print(err?.localizedDescription as Any)
                //Open Popup To Create New Acccoount Alert
                let signInPopUp = UIAlertController(title: "Create Your Account", message: err?.localizedDescription, preferredStyle: .alert)
                
                //Action For Go Register Page
                signInPopUp.addAction(UIAlertAction(title: "Register", style: .default, handler: { (action) in
                    
                    //Segue For Navigate Next Page
                    self.performSegue(withIdentifier: "RegisterPage", sender: self)
                }))
                signInPopUp.addAction(UIAlertAction(title: "Try Another", style: .default, handler: { (alert) in
                    //
                }))
                
                self.present(signInPopUp, animated: true, completion:nil)
            }else // If Error Is Nill Then User Succcessfully Login Works
            {
                self.performSegue(withIdentifier: "Chats", sender: self)
            }
        }
    }
    //For New User Create New Account
    @IBAction func CreatNewAcount(_ sender: UIButton) {
        //Segue For Navigate Next Page
        self.performSegue(withIdentifier: "RegisterPage", sender: self)
    }
    
    
}
extension UIViewController{
    //Error Popup Commen Popup Declare For Many Time Use
    func Errorpopup(message:String){
        let alertVC = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            //
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
}
//Email Validation For Registration And Login
extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}

extension UIViewController{
    
    class func showUniversalLoadingView(_ show: Bool, loadingText : String = "") {
        let existingView = UIApplication.shared.windows[0].viewWithTag(1200)
        if show {
            if existingView != nil {
                return
            }
            let loadingView = self.makeLoadingView(withFrame: UIScreen.main.bounds, loadingText: loadingText)
            loadingView?.tag = 1200
            UIApplication.shared.windows[0].addSubview(loadingView!)
        } else {
            existingView?.removeFromSuperview()
        }
        
    }
    
    
    // process view
    class func makeLoadingView(withFrame frame: CGRect, loadingText text: String?) -> UIView? {
        let loadingView = UIView(frame: frame)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        //activityIndicator.backgroundColor = UIColor(red:0.16, green:0.17, blue:0.21, alpha:1)
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = loadingView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        activityIndicator.tag = 100 // 100 for example
        
        loadingView.addSubview(activityIndicator)
        if !text!.isEmpty {
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            let cpoint = CGPoint(x: activityIndicator.frame.origin.x + activityIndicator.frame.size.width / 2, y: activityIndicator.frame.origin.y + 80)
            lbl.center = cpoint
            lbl.textColor = UIColor.white
            lbl.textAlignment = .center
            lbl.text = text
            lbl.tag = 1234
            loadingView.addSubview(lbl)
        }
        return loadingView
    }
}

