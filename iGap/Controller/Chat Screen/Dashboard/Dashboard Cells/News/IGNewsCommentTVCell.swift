/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */
import UIKit

class IGNewsCommentTVCell: UITableViewCell {
    
    
    
    @IBOutlet weak var lblDate : UILabel!
    @IBOutlet weak var lblAuthor : UILabel!
    @IBOutlet weak var lblComment : UILabel!
    @IBOutlet weak var bgView : UIView!

    var articleID : String = ""
    var item : IGStructNewsComment!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    private func initView() {
        lblDate.font = UIFont.igFont(ofSize: 12)
        lblAuthor.font = UIFont.igFont(ofSize: 12)
        lblComment.font = UIFont.igFont(ofSize: 12)
        bgView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        bgView.layer.cornerRadius = 5
        initAlignments()
    }
    private func initAlignments() {

        lblComment.textAlignment = lblComment.localizedDirection
        lblAuthor.textAlignment = .right
        lblDate.textAlignment = .left
        
    }
    func setCellData() {
        
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: item.commentDate!.checkTime())
        self.lblDate.text = date!.completeHumanReadableTime(showHour: true) ?? "..."
        
        self.lblAuthor.text = ": " + item.userName!
        self.lblComment.text = item.commentContent!
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    

}
