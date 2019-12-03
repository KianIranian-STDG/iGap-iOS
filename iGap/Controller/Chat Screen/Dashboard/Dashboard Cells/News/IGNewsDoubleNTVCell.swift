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

class IGNewsDoubleNTVCell: UITableViewCell {

    @IBOutlet weak var lblTitle0 : UILabel!
    @IBOutlet weak var lblTitleTwo0 : UILabel!
    @IBOutlet weak var lblAlias0 : UILabel!
    @IBOutlet weak var imgView0 : UIImageView!
    @IBOutlet weak var bgView0 : UIView!

    @IBOutlet weak var lblTitle1 : UILabel!
    @IBOutlet weak var lblTitleTwo1 : UILabel!
    @IBOutlet weak var lblAlias1 : UILabel!
    @IBOutlet weak var imgView1 : UIImageView!
    @IBOutlet weak var bgView1 : UIView!

    var newsOne: [newsInner]!
    var newsTwo: [newsInner]!

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
        lblAlias0.font = UIFont.igFont(ofSize: 12)
        lblTitle0.font = UIFont.igFont(ofSize: 12)
        lblTitleTwo0.font = UIFont.igFont(ofSize: 12)
        imgView0.layer.cornerRadius = 5
        bgView0.layer.cornerRadius = 5

        lblAlias1.font = UIFont.igFont(ofSize: 12)
        lblTitle1.font = UIFont.igFont(ofSize: 12)
        lblTitleTwo1.font = UIFont.igFont(ofSize: 12)
        imgView1.layer.cornerRadius = 5
        bgView1.layer.cornerRadius = 5
        initAlignments()
    }
    private func initAlignments() {
         let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
            imgView0.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
            lblTitle0.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
            lblTitleTwo0.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
            lblAlias0.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
            lblTitle0.textAlignment = lblTitle0.localizedDirection
            lblTitleTwo0.textAlignment = lblTitle0.localizedDirection
            lblAlias0.textAlignment = lblAlias0.localizedDirection

        imgView1.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitle1.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitleTwo1.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblAlias1.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitle1.textAlignment = lblTitle1.localizedDirection
        lblTitleTwo1.textAlignment = lblTitle1.localizedDirection
        lblAlias1.textAlignment = lblAlias1.localizedDirection

    }
    func setCellData() {
        self.bgView0.backgroundColor = UIColor.hexStringToUIColor(hex: newsOne[0].color!)
        self.bgView1.backgroundColor = UIColor.hexStringToUIColor(hex: newsTwo[0].color!)
        let urlStringFirst = newsOne[0].contents?.image![0].Original
        let urlStringSecond = newsTwo[0].contents?.image![0].Original
        let urlFirst = URL(string: urlStringFirst!)
        let urlSecond = URL(string: urlStringSecond!)
        //set images of double news Titles
        imgView0.sd_setImage(with: urlFirst, placeholderImage: UIImage(named :"1"), completed: nil)
        imgView1.sd_setImage(with: urlSecond, placeholderImage: UIImage(named :"1"), completed: nil)
        //set Color of double news Titles
        lblTitle0.textColor = UIColor.hexStringToUIColor(hex: newsOne[0].colorTitr!)
        lblTitle1.textColor = UIColor.hexStringToUIColor(hex: newsTwo[0].colorTitr!)
        lblTitleTwo0.textColor = UIColor.hexStringToUIColor(hex: newsOne[0].colorTitr!)
        lblTitleTwo1.textColor = UIColor.hexStringToUIColor(hex: newsTwo[0].colorTitr!)
        //set text of double news RooTitr
        lblTitleTwo0.text = newsOne[0].contents?.rootitr
        lblTitleTwo1.text = newsTwo[0].contents?.rootitr
        //set text of double news Alias
        lblAlias0.text = newsOne[0].contents?.titr
        lblAlias1.text = newsTwo[0].contents?.titr




    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
