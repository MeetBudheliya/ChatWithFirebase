//
//  ViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {

    @IBOutlet weak var LoginBTN: UIButton!
    @IBOutlet weak var PassWordTXT: UITextField!
    @IBOutlet weak var EmailTXT: UITextField!
    override func viewDidLoad() {
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
                //Open Popup To Create New Acccoount Alert
                let signInPopUp = UIAlertController(title: "Create Your Account", message: "This Account Is Not Reguster Yet!", preferredStyle: .alert)
                
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
                self.Errorpopup(message: "SucccessFully Login As \(res?.user.displayName)")
                
            }
        }
    }
    

}
extension UIViewController{
    func Errorpopup(message:String){
           let alertVC = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
           alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
               //
           }))
           self.present(alertVC, animated: true, completion: nil)
       }
}
extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
