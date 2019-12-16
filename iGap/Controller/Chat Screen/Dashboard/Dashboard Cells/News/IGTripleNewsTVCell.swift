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

class IGTripleNewsTVCell: UITableViewCell {
    
    @IBOutlet weak var imgOne : UIImageView!
    @IBOutlet weak var imgTwo : UIImageView!
    @IBOutlet weak var imgThree : UIImageView!
    
    @IBOutlet weak var lblTitleOne : UILabel!
    @IBOutlet weak var lblTitleTwo : UILabel!
    @IBOutlet weak var lblTitleThree : UILabel!
    
    @IBOutlet weak var BGViewOne : UIView!
    @IBOutlet weak var BGViewTwo : UIView!
    @IBOutlet weak var BGViewThree : UIView!
    
    var newsOne: [newsInner]!
    var newsTwo: [newsInner]!
    var newsThree: [newsInner]!
    var categoryIDOne : String! = "0"
    var categoryIDTwo : String! = "0"
    var categoryIDThree : String! = "0"
    var categoryOne : String! = ""
    var categoryTwo : String! = ""
    var categoryThree : String! = ""

    
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
        lblTitleOne.font = UIFont.igFont(ofSize: 12)
        lblTitleTwo.font = UIFont.igFont(ofSize: 12)
        lblTitleThree.font = UIFont.igFont(ofSize: 12)
        imgOne.layer.cornerRadius = 5
        imgTwo.layer.cornerRadius = 5
        imgThree.layer.cornerRadius = 5
        BGViewOne.layer.cornerRadius = 5
        BGViewTwo.layer.cornerRadius = 5
        BGViewThree.layer.cornerRadius = 5
        
        initAlignments()
    }
    private func initAlignments() {
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        
        imgOne.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        imgTwo.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        imgThree.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitleOne.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitleTwo.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitleThree.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        lblTitleOne.textAlignment = .right
        lblTitleTwo.textAlignment = .right
        lblTitleThree.textAlignment = .right
        
        
    }
    
    func setCellData() {
        self.BGViewOne.backgroundColor = UIColor.hexStringToUIColor(hex: newsOne[0].color!)
        self.BGViewTwo.backgroundColor = UIColor.hexStringToUIColor(hex: newsTwo[0].color!)
        self.BGViewThree.backgroundColor = UIColor.hexStringToUIColor(hex: newsThree[0].color!)
        let urlStringFirst = newsOne[0].contents?.image![0].Original
        let urlStringSecond = newsTwo[0].contents?.image![0].Original
        let urlStringThird = newsThree[0].contents?.image![0].Original
        let urlFirst = URL(string: urlStringFirst!)
        let urlSecond = URL(string: urlStringSecond!)
        let urlThird = URL(string: urlStringThird!)
        //set images of double news Titles
        imgOne.sd_setImage(with: urlFirst, placeholderImage: UIImage(named :"1"), completed: nil)
        imgTwo.sd_setImage(with: urlSecond, placeholderImage: UIImage(named :"1"), completed: nil)
        imgThree.sd_setImage(with: urlThird, placeholderImage: UIImage(named :"1"), completed: nil)
        //set Color of double news Titles
        lblTitleOne.textColor = UIColor.hexStringToUIColor(hex: newsOne[0].colorTitr!)
        lblTitleTwo.textColor = UIColor.hexStringToUIColor(hex: newsTwo[0].colorTitr!)
        lblTitleThree.textColor = UIColor.hexStringToUIColor(hex: newsThree[0].colorTitr!)
        //set text of double news Alias

    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func didTapOnNewsTwo(_ sender: UIButton) {
        let newsInner = IGNewsSectionInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
        
        newsInner.categoryID = categoryIDTwo
        newsInner.category = categoryTwo

        UIApplication.topViewController()!.navigationController!.pushViewController(newsInner, animated: true)
        
    }
    
    @IBAction func didTapOnNewsOne(_ sender: UIButton) {
        let newsInner = IGNewsSectionInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
        
        newsInner.categoryID = categoryIDOne
        newsInner.category = categoryOne
        UIApplication.topViewController()!.navigationController!.pushViewController(newsInner, animated: true)
        
    }
    @IBAction func didTapOnNewsThree(_ sender: UIButton) {
        let newsInner = IGNewsSectionInnerTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
        
        newsInner.categoryID = categoryIDThree
        newsInner.category = categoryThree
        UIApplication.topViewController()!.navigationController!.pushViewController(newsInner, animated: true)
        
    }
}
