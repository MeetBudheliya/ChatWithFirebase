//
//  SignUpViewController.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
class SignUpViewController: UIViewController {

    @IBOutlet weak var UserName: UITextField!
    @IBOutlet weak var EmailTXT: UITextField!
    @IBOutlet weak var PassTXT: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func SelectProfileImage(_ sender: UIButton) {
        imagePicker()
    }
    @IBAction func register(_ sender: UIButton) {
        guard let userName = UserName.text ,UserName.text != "" else {
            Errorpopup(message: "Fill UserName Field")
            return
        }
        guard let email = EmailTXT.text ,EmailTXT.text != "" else {
            Errorpopup(message: "Fill Email Field")
            return
        }
        guard  let pass = PassTXT.text ,PassTXT.text != "" else {
            Errorpopup(message: "Fill Password Field")
            return
        }
        guard email.isValidEmail else {
            Errorpopup(message: "Enter Valid Email")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
            guard error == nil else {
                self.Errorpopup(message: error!.localizedDescription)
                return
            }
            let imageName = UUID().uuidString
            let PImage = self.profileImage.image
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
                        let values = ["UserName":userName,"EmailId":email,"ProfileImage":Imageurl.absoluteString]
                        self.AddIntoUserList(uid: (result?.user.uid)!, values: values as [String:String])
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)

        }
    }
    func AddIntoUserList(uid:String,values:[String:String]){
        let ref = Database.database().reference()
        let userRes = ref.child("user").child(uid)
        userRes.updateChildValues(values) { (err, dbRef) in
            guard err == nil else{
                self.Errorpopup(message: err!.localizedDescription)
                return
            }
            self.Errorpopup(message: "SucccessFully Register")
        }
    }
}
//MARK: - Image Picker
extension SignUpViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
        profileImage.image = storeImg
        profileImage.contentMode = .scaleToFill
        self.dismiss(animated: true, completion: nil)
        
    }
}