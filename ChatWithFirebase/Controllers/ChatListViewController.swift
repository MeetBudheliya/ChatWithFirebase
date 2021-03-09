//
//  ChatListViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import FirebaseDatabase
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
        Database.database().reference().child("user").observe(.childAdded) { (snapShot) in
            print(snapShot.value!)
            
            //Append User Data into UserData Variable
            self.userData.append(User(id: snapShot.key, Dict: (snapShot.value as? [String:Any])!))
            
            //Reload Table For Assign Data Of Users
            self.ChatListTBL.reloadSections([0], with: .right)
            
        } withCancel: { (error) in
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
        
        //Set Rounded Image
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.borderColor = UIColor.black.cgColor
        
        //Setup All Data Into Table Cell
        cell.name.text = userData[indexPath.row].name
        cell.messageLBL.text = userData[indexPath.row].email
        //Decode Image Url Into Imager Formate And Set It Into Profile Image
        let imageurl = URL(string: userData[indexPath.row].profileImage!)
        URLSession.shared.dataTask(with: imageurl!) { (data, response, error) in
            guard error == nil else{
                self.Errorpopup(message:error!.localizedDescription)
                return
            }
            guard let image = data else{
                cell.profileImage.image = UIImage(systemName: "person.circle.fill")
                return
            }
            //set Image inro cell
            cell.profileImage.image = UIImage(data: image)
        }.resume()
        
        return cell
    }
    
    
}
