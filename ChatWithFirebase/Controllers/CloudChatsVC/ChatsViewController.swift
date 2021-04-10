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
import FirebaseStorage

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var ChatsTBL: UITableView!
    @IBOutlet weak var createGroupBTN: UIButton!
    @IBOutlet weak var joinGroupBTN: UIButton!
    let db = Firestore.firestore()
    var users = [UserList]()
    var groups = [NSDictionary]()
    var currentUser:UserList?
    var isNewCreate = 0
    var isJoin = 0
    var isOpenChat = true
    var isJoinAgain = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: "Login")
        tableSetup()
        //        GetUsers()
        GetList()
    }
    override func viewDidAppear(_ animated: Bool) {
        // GetUsers()
        isNewCreate = 0
        isJoin = 0
        isOpenChat = true
        self.joinGroupBTN.setTitle("Join Group", for: .normal)
        self.createGroupBTN.setTitle("Create Group", for: .normal)
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
    
    
    @IBAction func joinGroup(_ sender: Any) {
       JoinGroup()
    }
    @IBAction func createGroupClicked(_ sender: Any) {
        print("Create Group")
        CreateGroupBTNClick()
    }
    
    //Add Group Button Action Function
    //MARK: - Create Group
    func CreateGroupBTNClick(){
        if isJoin == 0{
            if isNewCreate == 0{
                self.ChatsTBL.allowsMultipleSelection = true
                self.createGroupBTN.setTitle("Confirm", for: .normal)
                self.navigationItem.title = "Select Users"
                isNewCreate = 1
                isOpenChat = false
                self.joinGroupBTN.setTitle("Cancel", for: .normal)
                
                var usersList = [UserList]()
                for user in users {
                    if user.type == "person"{
                        usersList.append(user)
                    }
                }
                self.users = usersList
                self.ChatsTBL.reloadData()
            }else if isNewCreate == 1{
                guard let selcted = self.ChatsTBL.indexPathsForSelectedRows else{
                    self.Errorpopup(message: "Select User To Make Group")
                    return
                }
                
                
                var NewGroupUsers  = [self.currentUser?.email]
                for index in selcted{
                    let ind = index.row
                    let usr = self.users[ind].email
                    NewGroupUsers.append(usr)
                }
                
                let popup = UIAlertController(title: "Create Group", message: "Enter Group Name", preferredStyle: .alert)
                popup.addAction(UIAlertAction(title: "Create", style: .default, handler: { (alert) in
                    guard let GroupName = popup.textFields![0].text else{
                        return
                    }
                    //                var usersEmail = [self.currentUser?.email]
                    //                for user in self.users{
                    //                    usersEmail.append(user.email!)
                    //                }
                    let imageName = UUID().uuidString
                    
                    let PImage = UIImage(named: "NC")
                    let storageRef = Storage.storage().reference().child("ProfileImages").child("\(imageName).png")
                    if let UploadProfile = PImage?.jpegData(compressionQuality: 1.0){
                        storageRef.putData(UploadProfile, metadata: nil) { (StorageData, err) in
                            guard err == nil else{
                                self.Errorpopup(message: err!.localizedDescription)
                                return
                            }
                            storageRef.downloadURL { (url, errr) in
                                guard errr == nil else{
                                    self.Errorpopup(message: errr!.localizedDescription)
                                    return
                                }
                                guard let Imageurl = url else{
                                    self.Errorpopup(message: "Image Url Not Found")
                                    return
                                }
                                
                                let id = UUID().uuidString
                                let data: [String: Any] = [
                                    "Id": id,
                                    "UserName": GroupName,
                                    "Members":NewGroupUsers,
                                    "EmailId":NewGroupUsers[0]!,
                                    "ProfileImage":Imageurl.absoluteString,
                                    "Type":"group",
                                    "Updated":Timestamp()
                                ]
                                
                                self.createNewGroup(id: id,data: data)  // Function For Create New Group From Selected Persons
                            }
                        }
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
        }else{
            print("JoinCancel")
            self.createGroupBTN.setTitle("Create Group", for: .normal)
            self.navigationItem.title = self.currentUser?.name
            self.GetList()
            self.isJoin = 0
            self.isOpenChat = true
        }
        
    }
    
    //MARK: - Create Group Function
    func createNewGroup(id:String ,data: [String: Any]){
        db.collection("Users").document(id).setData(data, completion: { (err) in
            guard err == nil else{
                print(err!)
                return
            }
            print(data)
            self.joinGroupBTN.setTitle("Join Group", for: .normal)
            self.navigationItem.title = self.currentUser?.name
            self.createGroupBTN.setTitle("Create Group", for: .normal)
            self.isNewCreate = 0
            self.isOpenChat = true
            self.ChatsTBL.allowsMultipleSelection = false
            //  self.users.append(UserList(Dict: data))
            self.ChatsTBL.reloadData()
        })
    }
    
    //MARK: - Join Group
    func JoinGroup(){
        if isNewCreate == 0{
            if isJoinAgain{
                self.Errorpopup(message: "Select For Join")
            }else{
                isJoinAgain = true
            }
            print("JoinClick")
//                var usersList = [UserList]()
//                for user in users {
//                    if user.type == "group"{
//                        usersList.append(user)
//                    }
//                }
//                self.users = usersList
            self.GetGroups()
                self.ChatsTBL.reloadData()
                self.createGroupBTN.setTitle("Cancel", for: .normal)
                self.isJoin = 1
            self.isOpenChat = false
            self.navigationItem.title = "Select Group"
            
        }else{
            self.joinGroupBTN.setTitle("Join Group", for: .normal)
            self.navigationItem.title = self.currentUser?.name
            self.createGroupBTN.setTitle("Create Group", for: .normal)
            self.isNewCreate = 0
            self.isOpenChat = true
            self.ChatsTBL.allowsMultipleSelection = false
            self.GetList()
            print("Cancel")
        }
    }
    
}

//MARK: - Get User List From FireStore Registered Users
extension ChatsViewController{
    func GetList(){
        ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        db.collection("Users").order(by: "Updated").addSnapshotListener { (snapshot, error) in
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
                    self.navigationItem.title = self.currentUser?.name
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
    
    func GetGroups(){
        ChatsViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        db.collection("Users").order(by: "Updated").addSnapshotListener { (snapshot, error) in
            guard error == nil else{
                ChatsViewController.showUniversalLoadingView(false)
                return
            }
            self.users = []
            for gData in snapshot!.documents{
                let data = gData.data()
                let type = data["Type"] as? String
                if type == "group"{
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
    
    cell.name.text = users[indexPath.row].name
    if users[indexPath.row].type == "person"{
        cell.messageLBL.text = users[indexPath.row].email
        cell.gIconImage.isHidden = true
    }else if users[indexPath.row].type == "group"{
        
        cell.gIconImage.isHidden = false
        cell.profileImage.isHidden = true
        var firstChar = [Character]()
        for char in users[indexPath.row].name! {
            firstChar.append(char)
        }
        
        cell.gIconImage.text = "\(firstChar[0].uppercased())"
        cell.messageLBL.text = "\(users[indexPath.row].members!.count) Members"
    }
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
    print(users[indexPath.row].id as Any)
    return cell
}
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isOpenChat{
            tableView.deselectRow(at: indexPath, animated: true)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CloudMessageVC") as! CloudMessageVC
            vc.receiverUser = users[indexPath.row]
            vc.currentUser = currentUser
            vc.type = users[indexPath.row].type!
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            print("\(indexPath.row) Selected")
           
            if isJoin == 1{
                print("Join : \(indexPath.row)")
                tableView.deselectRow(at: indexPath, animated: true)
                if users[indexPath.row].members?.contains((Auth.auth().currentUser?.email)!) == true{
                    self.Errorpopup(message: "You Are Already In This Group")
                }else{
                    let alert = UIAlertController(title: "Join \((users[indexPath.row].name)!)", message: "Are You Sure", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Join", style: .default, handler: { (okClick) in
                        print("Joined \((self.users[indexPath.row].name)!)")
                        

                        var updated = self.users[indexPath.row].members!
                        updated.append((Auth.auth().currentUser?.email)!)
                        let data: [String: Any] = [
                            "Members":updated,
                            "Updated":Timestamp()
                        ]
                        self.db.collection("Users").document(self.users[indexPath.row].id!).updateData(data) { (err) in
                            guard err == nil else{
                                print()
                                return
                            }
                        }
                        
                        
                        //After Joined All Data Reload
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CloudMessageVC") as! CloudMessageVC
                        vc.receiverUser = self.users[indexPath.row]
                        vc.currentUser = self.currentUser
                        vc.type = self.users[indexPath.row].type!
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (cancel) in
                        print("JoinCancel")
                        tableView.deselectRow(at: indexPath, animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
//            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
//            cell.profileImage.image = UIImage(named: "C")
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) Deselected")
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! ListCell
//        cell.profileImage.image = UIImage(named: "NC")
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            print("\(indexPath.row) Deleted")
            users.remove(at: indexPath.row)
            self.ChatsTBL.reloadData()
            
            //MARK: - Delete from Firestore but not delete from Authentication
//            db.collection("Users").getDocuments(completion: { (snap, err) in
//
//                for data in snap!.documents{
//                    let usr = data.data() as NSDictionary
//                    if self.users[indexPath.row].id == usr.value(forKey: "Id") as? String && self.users[indexPath.row].id != nil{
//
//
//                        self.db.collection("Users").document(self.users[indexPath.row].id!).delete()
//
//                        print("\(self.users[indexPath.row].name!) Deleted")
//                    }
//
//                }
//            })
        }
    }
}


//MARK: - Shadow Setup
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

//MARK: - Get Message Time
extension UIViewController{
    func gettimefromDate(date:Date)->String{
        let dateFormetter = DateFormatter()
        dateFormetter.dateFormat = "dd/MM/YY h:mm a"
        return dateFormetter.string(from: date)
    }
}
