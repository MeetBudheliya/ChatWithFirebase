//
//  RightCell.swift
//  ChatWithFirebase
//
//  Created by MAC on 09/03/21.
//

import UIKit

class RightCell: UITableViewCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var msg: UILabel!
    @IBOutlet weak var msgView: UIView!
    
    @IBOutlet weak var receiverProfile: UIImageView!
    @IBOutlet weak var receiverTime: UILabel!
    @IBOutlet weak var receiverMsg: UILabel!
    @IBOutlet weak var receiverMsgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        //Set Rounded Image
        profile.layer.borderWidth = 0.5
        profile.layer.masksToBounds = false
        profile.layer.borderColor = UIColor.black.cgColor
        profile.clipsToBounds = true
        profile.layer.cornerRadius = profile.frame.height/2
        
        msgView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
        
        //Set Rounded Image
        receiverProfile.layer.borderWidth = 0.5
        receiverProfile.layer.masksToBounds = false
        receiverProfile.layer.borderColor = UIColor.black.cgColor
        receiverProfile.clipsToBounds = true
        receiverProfile.layer.cornerRadius = receiverProfile.frame.height/2
        
        receiverMsgView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
