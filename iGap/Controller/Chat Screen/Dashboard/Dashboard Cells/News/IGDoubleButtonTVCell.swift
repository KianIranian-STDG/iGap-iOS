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

class IGDoubleButtonTVCell: UITableViewCell {

    @IBOutlet weak var btnOne : UIButton!
    @IBOutlet weak var btnTwo : UIButton!
    
    var categoryIDOne : String! = "0"
    var categoryIDTwo : String! = "0"
    var categoryOne : String! = ""
    var categoryTwo : String! = ""

    
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
        btnOne.titleLabel?.font = UIFont.igFont(ofSize: 15)
        btnTwo.titleLabel?.font = UIFont.igFont(ofSize: 15)
        
        btnOne.layer.cornerRadius = 5
        btnTwo.layer.cornerRadius = 5
        initAlignments()
    }
    private func initAlignments() {
         let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        
            btnOne.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
            btnTwo.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)

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
    
}
