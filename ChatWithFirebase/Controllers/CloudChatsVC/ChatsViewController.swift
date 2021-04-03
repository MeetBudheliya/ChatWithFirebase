//
//  ChatsViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseFirestore

class ChatsViewController: UIViewController {

    @IBOutlet weak var ChatsTBL: UITableView!
    var users = [User]()
    var currentUser:User?
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: "Login")
        tableSetup()
        GetUsers()
    }
    
    func tableSetup(){
        ChatsTBL.delegate = self
        ChatsTBL.dataSource = self
        ChatsTBL.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
    }
    @IBAction func SignOut(_ sender: UIBarButtonItem) {
        UserDefaults.resetStandardUserDefaults()
        self.performSegue(withIdentifier: "SignOutClicked", sender: self)
    }
    @IBAction func userListClicked(_ sender: UIBarButtonItem) {
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }


}

//MARK: - Get User List From RealTime Registered
extension ChatsViewController{
    func GetUsers(){
        ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        Database.database().reference().child("user").observe(.childAdded) { (snapshot) in
            print(snapshot)
            let key = snapshot.key
            let user = snapshot.value as? [String:Any]
            let userEmail = user!["EmailId"] as? String
            
            
            if Auth.auth().currentUser?.email == userEmail?.lowercased(){
                self.currentUser = User(id: key, Dict: user!)
                //Condition For current User In Not See In List
                
            }else{
                // Exclude Current UYser All User See In List
                self.users.append(User(id: key, Dict: user!))
            }
            self.ChatsTBL.reloadData()
            ChatsViewController.showUniversalLoadingView(false)
            
//            //Add Into Cloud Storage
//            let data: [String: Any] = [
//                "users":self.currentUser?.email!
//            ]
//            Firestore.firestore().collection("Chats").addDocument(data: data) { (err) in
//                guard err == nil else{
//                    print(err!)
//                    return
//                }
//                print(data)
//            }
            
        }
    }
    
  
}
//MARK: - Table View Setup
extension ChatsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
        cell.name.text = users[indexPath.row].name
        cell.messageLBL.text = users[indexPath.row].email
        cell.timeLBL.text = users[indexPath.row].createdDate
        
        // Load Image From Url
       // ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        if users[indexPath.row].profileImage != nil{
            URLSession.shared.dataTask(with: URL(string: users[indexPath.row].profileImage!)!) { (data, response, error) in
                guard error == nil else{
                    cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                    ChatsViewController.showUniversalLoadingView(false)
                    return
                }
                guard let imageData = data else{
                    cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                        ChatsViewController.showUniversalLoadingView(false)
                    return
                }
                
                DispatchQueue.main.async {
                    guard let image = UIImage(data: imageData) else{
                        cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                            ChatsViewController.showUniversalLoadingView(false)
                        return
                    }
                    ChatsViewController.showUniversalLoadingView(false)
                    cell.profileImage.image = image
                }
            }.resume()
        }else{
            ChatsViewController.showUniversalLoadingView(false)
            cell.profileImage.image = UIImage(systemName: "person.circle.fill")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CloudMessageVC") as! CloudMessageVC
        vc.receiverUser = users[indexPath.row]
        vc.currentUser = currentUser
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}



extension UIView{
    func SetShaowInView(){
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 7
        self.layer.cornerRadius = 10
    }
}
