//
//  ListCell.swift
//  ChatWithFirebase
//
//  Created by MAC on 08/03/21.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var messageLBL: UILabel!
    @IBOutlet weak var timeLBL: UILabel!
    @IBOutlet weak var createdLBL: UILabel!
    @IBOutlet weak var gIconImage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //Set Rounded Image
      //  profileImage.layer.borderWidth = 0.5
        profileImage.layer.masksToBounds = false
       //profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        profileImage.superview?.layer.cornerRadius = (profileImage.superview?.frame.height)!/2
        profileImage.superview?.layer.borderWidth = 0.5
        profileImage.superview?.layer.borderColor = UIColor.black.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
