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