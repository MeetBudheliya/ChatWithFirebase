//
//  ChatListViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ChatListViewController: UIViewController {

    @IBOutlet weak var ChatListTBL: UITableView!
    var userData = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
TableSetup()
        GetUserListFromRealTime()
    }
    //Table Setup
    func TableSetup(){
        ChatListTBL.delegate = self
        ChatListTBL.dataSource = self
        ChatListTBL.register(UINib(nibName: "ListCell", bundle:nil), forCellReuseIdentifier: "ListCell")
    }
    //Get User List Of Registered In Real Time Storage
    func GetUserListFromRealTime(){
        //Strt Loadr Till Load All Data In Page
        ChatListViewController.showUniversalLoadingView(true, loadingText: "Please Wait...")
        
        Database.database().reference().child("user").observe(.childAdded) { (snapShot) in
            print(snapShot.value!)
            
            let users = snapShot.value as? [String:Any]
            let userEmail = users!["EmailId"] as? String
            if Auth.auth().currentUser?.email == userEmail?.lowercased(){
                //Current User Will not Display Into Chat Screen
            }else{
                //Append User Data into UserData Variable
                self.userData.append(User(id: snapShot.key, Dict: (snapShot.value as? [String:Any])!))
            }
            
            //Reload Table For Assign Data Of Users
            self.ChatListTBL.reloadSections([0], with: .left)
            
            ChatListViewController.showUniversalLoadingView(false) // Stop Loader because All Data Is Loaded
        } withCancel: { (error) in
            ChatListViewController.showUniversalLoadingView(false) // Stop Loader Because error occurs
            //Popup For Any Errors
            self.Errorpopup(message: error.localizedDescription)
        }

    }
}
extension ChatListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Set Table Rows
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        

        //Setup All Data Into Table Cell
        cell.name.text = userData[indexPath.row].name
        cell.messageLBL.text = userData[indexPath.row].email
        cell.timeLBL.text = userData[indexPath.row].createdDate
        
        //Decode Image Url Into Imager Formate And Set It Into Profile Image
        let imageurl = URL(string: userData[indexPath.row].profileImage!)
        ChatListViewController.showUniversalLoadingView(true, loadingText: "Loading...")
        URLSession.shared.dataTask(with: imageurl!) { (data, response, error) in
            guard error == nil else{
                ChatListViewController.showUniversalLoadingView(false)
                self.Errorpopup(message:error!.localizedDescription)
                return
            }
            guard let image = data else{
                ChatListViewController.showUniversalLoadingView(false)
                cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                return
            }
            //set Image inro cell
            DispatchQueue.main.async {
                ChatListViewController.showUniversalLoadingView(false)
                cell.profileImage.image = UIImage(data: image)
            }
        }.resume()
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let MessageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        MessageVC.receiverUser = userData[indexPath.row]
        self.navigationController?.pushViewController(MessageVC, animated: true)
    }
}
