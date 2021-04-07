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
    @IBOutlet weak var createGroupBTN: UIButton!
    var users = [UserList]()
    var groups = [NSDictionary]()
    var currentUser:UserList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "Login")
        tableSetup()
        //        GetUsers()
        GetList()
    }
    override func viewDidAppear(_ animated: Bool) {
        // GetUsers()
        GetList()
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
    
    @IBAction func createGroupClicked(_ sender: Any) {
        print("Create Group")
        CreateGroupBTNClick()
    }
    //Add Group Button Action Function
    func CreateGroupBTNClick(){
        let popup = UIAlertController(title: "Create Group", message: "Enter Group Name", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Create", style: .default, handler: { (alert) in
            guard let GroupName = popup.textFields![0].text else{
                return
            }
            var usersEmail = [self.currentUser?.email]
            for user in self.users{
                usersEmail.append(user.email!)
            }
            let data: [String: Any] = [
                "UserName": GroupName,
                "Members":usersEmail,
                "EmailId":usersEmail[0]!,
                "Type":"group",
                "Updated":Timestamp()
            ]
            Firestore.firestore().collection("Users").addDocument(data: data) { (err) in
                guard err == nil else{
                    print(err!)
                    return
                }
                print(data)
              //  self.users.append(UserList(Dict: data))
                self.ChatsTBL.reloadData()
            }
            
        }))
        popup.addTextField { (textField) in
            textField.placeholder = "Enter Group Name Here"
        }
        popup.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (alert) in
            //
        }))
        self.present(popup, animated: true, completion: nil)
    }
    
}

//MARK: - Get User List From RealTime Registered
extension ChatsViewController{
    func GetUsers(){
        //        self.users = []
        //        ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        //        Database.database().reference().child("user").observe(.childAdded) { (snapshot) in
        //            print(snapshot)
        //            let key = snapshot.key
        //            let user = snapshot.value as? [String:Any]
        //            let userEmail = user!["EmailId"] as? String
        //
        //
        //            if Auth.auth().currentUser?.email == userEmail?.lowercased(){
        //                self.currentUser = User(id: key, Dict: user!)
        //                //Condition For current User In Not See In List
        //
        //            }else{
        //                // Exclude Current UYser All User See In List
        //                self.users.append(User(id: key, Dict: user!))
        //            }
        //            self.ChatsTBL.reloadData()
        //            ChatsViewController.showUniversalLoadingView(false)
        //        }
    }
    func GetList(){
        ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        Firestore.firestore().collection("Users").order(by: "Updated").addSnapshotListener { (snapshot, error) in
            guard error == nil else{
                ChatsViewController.showUniversalLoadingView(false)
                return
            }
            self.users = []
            for gData in snapshot!.documents{
               let data = gData.data()
                let usr = data["EmailId"] as? String
                let type = data["Type"] as? String
                let members = data["Members"] as? [String]
                if Auth.auth().currentUser?.email == usr!.lowercased() && type == "person"{
                    self.currentUser = UserList(Dict: gData.data())
                    //Condition For current User In Not See In List
                    
                }else if type == "group" && members?.contains((Auth.auth().currentUser?.email)!) == true{
                    // Exclude Current UYser All User See In List
                    self.users.append(UserList(Dict: gData.data()))
                }else if Auth.auth().currentUser?.email != usr!.lowercased() && type == "person"{
                    // Exclude Current UYser All User See In List
                    self.users.append(UserList(Dict: gData.data()))
                }
            }
            self.ChatsTBL.reloadData()
            ChatsViewController.showUniversalLoadingView(false)
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
        
        //if indexPath.row < users.count{
        cell.name.text = users[indexPath.row].name
        cell.messageLBL.text = users[indexPath.row].email
        cell.timeLBL.text = self.gettimefromDate(date: (users[indexPath.row].Updated?.dateValue())!)
        
        // Load Image From Url
        // ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        if users[indexPath.row].profileImage != nil{
            URLSession.shared.dataTask(with: URL(string: users[indexPath.row].profileImage!)!) { (data, response, error) in
                guard error == nil else{
                    DispatchQueue.main.async {
                        cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                    }
                    ChatsViewController.showUniversalLoadingView(false)
                    return
                }
                guard let imageData = data else{
                    DispatchQueue.main.async {
                        cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                    }
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
            DispatchQueue.main.async {
                cell.profileImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
        // }
        //        else{
        //
        //            cell.createdLBL.isHidden = true
        //            cell.timeLBL.textAlignment = .center
        //            let groupIndex = indexPath.row - users.count
        //            cell.name.text = groups[groupIndex].value(forKey: "GroupName") as? String
        //            cell.messageLBL.text = "Admin:\(groups[groupIndex].value(forKey: "Admin")!)"
        //            let members = groups[groupIndex].value(forKey: "Users") as? [String]
        //            cell.timeLBL.text = "\(members!.count) Members"
        //        }
        
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
extension UIViewController{
    func gettimefromDate(date:Date)->String{
        let dateFormetter = DateFormatter()
        dateFormetter.dateFormat = "dd/MM/YY h:mm a"
        return dateFormetter.string(from: date)
    }
}
