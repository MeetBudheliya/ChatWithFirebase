//
//  User.swift
//  ChatWithFirebase
//
//  Created by MAC on 09/03/21.
//

import Foundation
class User: NSObject {
    var id:String?
    var name:String?
    var email :String?
    var profileImage:String?
    var createdDate:String?
    init(id:String,Dict:[String:Any]) {
        self.id = id
        self.name = Dict["UserName"] as? String
        self.email = Dict["EmailId"] as? String
        self.profileImage = Dict["ProfileImage"] as? String
        self.createdDate = Dict["CreatedDate"] as? String
    }
}
import FirebaseFirestore
class UserList: NSObject {
    var id:String?
    var name:String?
    var email :String?
    var profileImage:String?
    var Updated:Timestamp?
    var members:[String]?
    var type:String?
    init(Dict:[String:Any]) {
        self.id = Dict["Id"] as? String
        self.name = Dict["UserName"] as? String
       self.email = Dict["EmailId"] as? String
        self.profileImage = Dict["ProfileImage"] as? String
        self.Updated = Dict["Updated"] as? Timestamp
        self.members = Dict["Members"] as? [String]
        self.type = Dict["Type"] as? String
    }
}
