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
        Auth.auth().signIn(withEmail: email, password: pass) { (res, err) in
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
