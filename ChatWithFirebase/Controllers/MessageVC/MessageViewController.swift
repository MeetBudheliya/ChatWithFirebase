//
//  MessageViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 09/03/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
struct MsgData{
    var body:String?
    var sender:String?
    var receiver:String?
}
class MessageViewController: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var msgTBL: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var messages:MsgData?
    var messageData = [MsgData]()
    var receiverUser:User?
    var currentUserProfile = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = receiverUser?.name
        ViewShdow()
        GetProfileImageFromFirebase()
        MsgTableSetup()
        GetMessages()
    }
    func ViewShdow(){
        bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSize(width: -10, height: -10)
        bottomView.layer.shadowRadius = 10
    }
    func MsgTableSetup() {
        msgTBL.delegate = self
        msgTBL.dataSource = self
        msgTBL.register(UINib(nibName: "RightCell", bundle: nil), forCellReuseIdentifier: "RightCell")
    }
    @IBAction func photosClicked(_ sender: UIButton) {
    }
    @IBAction func EnterClicked(_ sender: UITextField) {
        //Assign Values into Commen Structure
        guard let msg = sender.text else {
            return
        }
        
        
        
        messages = MsgData(body: msg, sender: Auth.auth().currentUser?.email, receiver: receiverUser?.email)
        messageData.append(messages!)
        msgTBL.reloadData()
        sender.text = nil
        
        
        let values = ["Sender":messages?.sender as Any,"Receiver":messages?.receiver as Any,"Body":messages?.body as Any,"Time":getCurrentTime()] as [String:Any]
        self.AddMesssageIntoDatabase(values: values)
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3){ [self] in
        //
        //            let row = messageData.count
        //            msgTBL.scrollToRow(at: [0,row], at: .top, animated: true)
        //
        //        }
    }
    
}
//MARK: - Message Table Setup
extension MessageViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //number Of Rows in section
        return messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set Values Of Each Rows in tableview
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightCell") as! RightCell
        
        if messageData[indexPath.row].sender == Auth.auth().currentUser?.email{
            
            cell.msg.text = messageData[indexPath.row].body
            cell.time.text = getCurrentTime()
            cell.profile.image = currentUserProfile.image

        }else{
           
            cell.msg.text = messageData[indexPath.row].body
            cell.time.text = getCurrentTime()
            cell.profile.image = currentUserProfile.image
           
        }
        return cell
    }
    
}
//MARK: - Working With Realtime Databse
extension MessageViewController:UITextFieldDelegate{
    //Get Profile Image Data From Firebase Database
    func GetProfileImageFromFirebase() {
        //Get Image Ling From Database
        MessageViewController.showUniversalLoadingView(true, loadingText: "Loading...")
        Database.database().reference().child("user").observe(.childAdded) { (snapshot) in
            
            let users = snapshot.value as! [String:Any]
            
            if Auth.auth().currentUser?.email == users["EmailId"] as? String{
                let imageurl = URL(string: users["ProfileImage"] as! String)
                
                //Decode Image Url Into Imager Formate And Set It Into Profile Image
                URLSession.shared.dataTask(with: imageurl!) { (data, response, error) in
                    guard error == nil else{
                        MessageViewController.showUniversalLoadingView(false)
                        self.Errorpopup(message:error!.localizedDescription)
                        return
                    }
                    guard let image = data else{
                        MessageViewController.showUniversalLoadingView(false)
                        self.currentUserProfile.image = UIImage(systemName: "person.circle.fill")
                        return
                    }
                    //set Image inro cell
                    DispatchQueue.main.async {
                        MessageViewController.showUniversalLoadingView(false)
                        self.currentUserProfile.image = UIImage(data: image)
                    }
                }.resume()
            }
        } withCancel: { (error) in
            MessageViewController.showUniversalLoadingView(false)
            self.currentUserProfile.image = UIImage(systemName: "person.circle.fill")
            self.Errorpopup(message: error.localizedDescription)
            
        }
    }
    
    //Add New Message Into Firebase datbase
    func AddMesssageIntoDatabase(values:[String:Any]){
        let userMSGReference = Database.database().reference().child("Chats").childByAutoId()
        userMSGReference.updateChildValues(values) { (error, ref) in
            guard error == nil else{
                self.Errorpopup(message: "Something Went Wrong")
                return
            }
            print(ref)
        }
    }
    
    //Get All Messages of Current Recceiver
    func GetMessages(){
        let path = Database.database().reference().child("Chats")
        
        path.observe(.childAdded) { (snapshot) in
            let messages = snapshot.value as! [String:Any]
            if messages["Sender"] as? String == Auth.auth().currentUser?.email || messages["Receiver"] as? String == self.receiverUser?.email{
                self.messageData.append(MsgData(body: messages["Body"] as? String, sender: messages["Sender"] as? String, receiver: messages["Receiver"] as? String))
            }
            
        }
    }
}
extension MessageViewController{
    func getCurrentTime() -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: Date())
        
    }
    
}
