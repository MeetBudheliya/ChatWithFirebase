//
//  CloudMessageVC.swift
//  ChatWithFirebase
//
//  Created by Adsum MAC 1 on 03/04/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct Messagee{
    let receiverId:String?
    let sender:String?
    let receiver:[String]?
    let body:String?
    let messageTime:Timestamp?
    let type:String?
}
//protocol lastMsgTime {
//    func SendLastMSGTime(msg:String,time:String,receiver:String)
//}
class CloudMessageVC: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var msgTBL: UITableView!
    @IBOutlet weak var msgTXT: UITextField!
   // var delegate:lastMsgTime?
    let db = Firestore.firestore()
    var receiverUser:UserList?
    var currentUser:UserList?
    var messages = [Messagee]()
    var type = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = receiverUser?.name
        ViewShdow()
        tableSetup()
        loadMessage()
       
    }
    func ViewShdow(){
        bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSize(width: -10, height: -10)
        bottomView.layer.shadowRadius = 10
    }
    func tableSetup(){
        msgTBL.delegate = self
        msgTBL.dataSource = self
        msgTBL.register(UINib(nibName: "RightCell", bundle: nil), forCellReuseIdentifier: "RightCell")
    }
    @IBAction func EnterClicked(_ sender: UITextField) {
        guard sender.text != nil || sender.text != "" else {
            print("Enter Message")
            return
        }
        var receivers = [String]()
        if (receiverUser?.type)! == "person"{
            let receivertEmail = (receiverUser?.email)!
            receivers = [receivertEmail]
        }else if (receiverUser?.type)! == "group"{
            for receiverEmail in receiverUser!.members!{
                receivers.append(receiverEmail)
            }
        }
        
        AddNewMessage(msg: Messagee(receiverId:receiverUser?.id, sender: Auth.auth().currentUser?.email, receiver: receivers, body: sender.text, messageTime: Timestamp(),type: type))
        receivers = []
        sender.text = nil
    }
    @IBAction func folderButton(_ sender: UIButton) {
        imagePicker()
        
    }
    
}
extension CloudMessageVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightCell") as! RightCell
        let cellMSG = messages[indexPath.row]
        
        if type == "person"{
            if Auth.auth().currentUser?.email == cellMSG.sender && receiverUser?.email == cellMSG.receiver![0]{
                cell.receiverMsgView.isHidden = true
                cell.receiverProfile.isHidden = true
                cell.msgView.isHidden = false
                cell.profile.isHidden = false
                
                cell.msg.text = cellMSG.body
                cell.time.text = getTimeFromTimestamp(time: cellMSG.messageTime!)
                if let imgUrl = currentUser?.profileImage{
                    URLSession.shared.dataTask(with: URL(string: imgUrl)!) { (data, res, err) in
                        guard err == nil else{
                            print(err!)
                            DispatchQueue.main.async {
                                cell.profile.image =  UIImage(systemName: "person.circle.fill")
                            }
                            return
                        }
                        guard let imgData = data else{
                            DispatchQueue.main.async {
                                cell.profile.image =  UIImage(systemName: "person.circle.fill")
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            guard let image = UIImage(data: imgData) else{
                                cell.profile.image = UIImage(systemName: "person.circle.fill")
                                return
                            }
                            cell.profile.image =  image
                        }
                    }.resume()
                }else{
                    DispatchQueue.main.async {
                        cell.profile.image =  UIImage(systemName: "person.circle.fill")
                    }
                }
                
            }else if Auth.auth().currentUser?.email == cellMSG.receiver![0] && receiverUser?.email == cellMSG.sender{
                cell.receiverMsgView.isHidden = false
                cell.receiverProfile.isHidden = false
                cell.msgView.isHidden = true
                cell.profile.isHidden = true
                
                cell.receiverMsg.text = cellMSG.body
                cell.receiverTime.text = getTimeFromTimestamp(time: cellMSG.messageTime!)
                if let imgUrl = receiverUser?.profileImage{
                    URLSession.shared.dataTask(with: URL(string: imgUrl)!) { (data, res, err) in
                        guard err == nil else{
                            print(err!)
                            DispatchQueue.main.async {
                                cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
                            }
                            return
                        }
                        guard let imgData = data else{
                            DispatchQueue.main.async {
                                cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            guard let image = UIImage(data: imgData) else{
                                cell.receiverProfile.image = UIImage(systemName: "person.circle.fill")
                                return
                            }
                            cell.receiverProfile.image = image
                        }
                    }.resume()
                }else{
                    DispatchQueue.main.async {
                        cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
                    }
                }
            }
        }else if type == "group"{
            if Auth.auth().currentUser?.email == cellMSG.sender && receiverUser?.members == cellMSG.receiver{
                cell.receiverMsgView.isHidden = true
                cell.receiverProfile.isHidden = true
                cell.msgView.isHidden = false
                cell.profile.isHidden = false
                
                cell.msg.text = cellMSG.body
                cell.time.text = getTimeFromTimestamp(time: cellMSG.messageTime!)
//                if let imgUrl = currentUser?.profileImage{
//                    URLSession.shared.dataTask(with: URL(string: imgUrl)!) { (data, res, err) in
//                        guard err == nil else{
//                            print(err!)
//                            DispatchQueue.main.async {
//                                cell.profile.image =  UIImage(systemName: "person.circle.fill")
//                            }
//                            return
//                        }
//                        guard let imgData = data else{
//                            DispatchQueue.main.async {
//                                cell.profile.image =  UIImage(systemName: "person.circle.fill")
//                            }
//                            return
//                        }
//
//                        DispatchQueue.main.async {
//                            guard let image = UIImage(data: imgData) else{
//                                cell.profile.image = UIImage(systemName: "person.circle.fill")
//                                return
//                            }
//                            cell.profile.image =  image
//                        }
//                    }.resume()
//                }else{
//                    DispatchQueue.main.async {
//                        cell.profile.image =  UIImage(systemName: "person.circle.fill")
//                    }
//                }
                
            }else if receiverUser?.members == cellMSG.receiver{
                cell.receiverMsgView.isHidden = false
                cell.receiverProfile.isHidden = false
                cell.msgView.isHidden = true
                cell.profile.isHidden = true
                
                cell.receiverMsg.text = cellMSG.body
                cell.receiverTime.text = getTimeFromTimestamp(time: cellMSG.messageTime!)
//                if let imgUrl = receiverUser?.profileImage{
//                    URLSession.shared.dataTask(with: URL(string: imgUrl)!) { (data, res, err) in
//                        guard err == nil else{
//                            print(err!)
//                            DispatchQueue.main.async {
//                                cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
//                            }
//                            return
//                        }
//                        guard let imgData = data else{
//                            DispatchQueue.main.async {
//                                cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
//                            }
//                            return
//                        }
//
//                        DispatchQueue.main.async {
//                            guard let image = UIImage(data: imgData) else{
//                                cell.receiverProfile.image = UIImage(systemName: "person.circle.fill")
//                                return
//                            }
//                            cell.receiverProfile.image = image
//                        }
//                    }.resume()
//                }else{
//                    DispatchQueue.main.async {
//                        cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
//                    }
//                }
            }
        }
       // self.delegate?.SendLastMSGTime(msg: cellMSG.body!, time: getTimeFromTimestamp(time: cellMSG.messageTime!),receiver: (receiverUser?.email)!)
        
        return cell
    }
    
    
}
//MARK: - MessageData Setup
extension CloudMessageVC{
    
    func AddNewMessage(msg:Messagee){
        print(msg)
        messages.append(msg)
        self.msgTBL.reloadData()
        let index = IndexPath(row: self.messages.count-1, section: 0)
        self.msgTBL.scrollToRow(at: index, at: .top, animated: true)
      
        let data: [String: Any] = [
            "receiverId":msg.receiverId!,
            "sender": msg.sender!,
            "receiver": msg.receiver!,
            "body": msg.body!,
            "time": msg.messageTime!,
            "Type": msg.type!
        ]
        db.collection("MsgData").addDocument(data: data) { (err) in
            guard err == nil else{
                print(err!)
                return
            }
            print(data)
        }
    }
    
    func loadMessage(){
        
        db.collection("MsgData").order(by: "time").addSnapshotListener { (query, error) in
            
            self.messages = []
            guard error == nil else{
                print("There Was Some Issue")
                return
            }
            for msgData in query!.documents{
                let data = msgData.data()
                if self.type == "person"{
                    let receiver = data["receiver"] as? [String]
                    let receiverUser = receiver![0]
                    if receiver?.count == 1{
                        if (Auth.auth().currentUser?.email == data["sender"] as? String && (self.receiverUser?.email)! == receiverUser) || (Auth.auth().currentUser?.email == receiverUser && self.receiverUser?.email == data["sender"] as? String){
                            let msg = Messagee(receiverId:data["receiverId"] as? String, sender: data["sender"] as? String , receiver: [receiverUser], body: data["body"] as? String, messageTime: data["time"] as? Timestamp,type: data["Type"] as? String)
                            self.messages.append(msg)
                        }
                    }
                }else if self.type == "group"{
                    let members = data["receiver"] as? [String]
                    let GroupId = data["receiverId"] as? String
                    
                    if members?.contains((Auth.auth().currentUser?.email)!) == true && self.receiverUser?.members == members && self.receiverUser?.id == GroupId{
                        let msg = Messagee(receiverId:GroupId, sender: data["sender"] as? String , receiver: members, body: data["body"] as? String, messageTime: data["time"] as? Timestamp,type: data["Type"] as? String)
                        self.messages.append(msg)
                    }
                }
                
            }
            
            DispatchQueue.main.async {
                self.msgTBL.reloadData()
                if self.messages.count > 0{
                    let index = IndexPath(row: self.messages.count-1, section: 0)
                    self.msgTBL.scrollToRow(at: index, at: .top, animated: true)
                }
               
            }
            
        }
    }
}


//MARK: - Image Picker
extension CloudMessageVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePicker() {
        let alert = UIAlertController(title: "Change Profile", message:nil , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Albums", style: .default, handler: { (album) in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .photoLibrary
            image.allowsEditing = false
            self.present(image, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (album) in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = .camera
            image.allowsEditing = false
            self.present(image, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (cancel) in
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let storeImg = info[.originalImage] as! UIImage
//        profileImage.image = storeImg
//        profileImage.contentMode = .scaleToFill
        msgTXT.text = storeImg.description
        self.dismiss(animated: true, completion: nil)
        
    }
}

extension CloudMessageVC{
    func getTimeFromTimestamp(time:Timestamp) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: time.dateValue())
        
    }
}
