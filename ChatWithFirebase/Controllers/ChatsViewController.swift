//
//  ChatsViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit

class ChatsViewController: UIViewController {

    @IBOutlet weak var ChatsTBL: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: "Login")
    }
    @IBAction func SignOut(_ sender: UIBarButtonItem) {
        UserDefaults.resetStandardUserDefaults()
        self.performSegue(withIdentifier: "SignOutClicked", sender: self)
//        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNav") as! UINavigationController
//        self.navigationController?.pushViewController(VC, animated: true)
    }
    @IBAction func userListClicked(_ sender: UIBarButtonItem) {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        self.navigationController?.pushViewController(VC, animated: true)
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
