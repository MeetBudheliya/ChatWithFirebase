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
    let sender:String?
    let receiver:String?
    let body:String?
    let messageTime:Timestamp?
}
class CloudMessageVC: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var msgTBL: UITableView!
    @IBOutlet weak var msgTXT: UITextField!
    
    let db = Firestore.firestore()
    var receiverUser:User?
    var currentUser:User?
    var messages = [Messagee]()
    override func viewDidLoad() {
        super.viewDidLoad()

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
        AddNewMessage(msg: Messagee(sender: Auth.auth().currentUser?.email, receiver: receiverUser?.email, body: sender.text, messageTime: Timestamp()))
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
        
        if Auth.auth().currentUser?.email == cellMSG.sender{
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
                        cell.profile.image =  UIImage(systemName: "person.circle.fill")
                        return
                    }
                    guard let imgData = data else{
                        cell.profile.image =  UIImage(systemName: "person.circle.fill")
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
                cell.profile.image =  UIImage(systemName: "person.circle.fill")
            }
            
        }else{
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
                        cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
                        return
                    }
                    guard let imgData = data else{
                        cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
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
                cell.receiverProfile.image =  UIImage(systemName: "person.circle.fill")
            }
        }
        
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
            "sender": msg.sender!,
            "receiver": msg.receiver!,
            "body": msg.body!,
            "time": msg.messageTime!,
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
                let msg = Messagee(sender: data["sender"] as? String , receiver: data["receiver"] as? String, body: data["body"] as? String, messageTime: data["time"] as? Timestamp)
                self.messages.append(msg)
            }
            
            DispatchQueue.main.async {
                self.msgTBL.reloadData()
                let index = IndexPath(row: self.messages.count-1, section: 0)
                self.msgTBL.scrollToRow(at: index, at: .top, animated: true)
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
