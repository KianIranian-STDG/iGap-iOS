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
import MBProgressHUD
import IGProtoBuff

class IGRegistrationStepPrivacyPolicyViewController: BaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var body : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigaitonItem = self.navigationItem as! IGNavigationItem
        navigaitonItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PS_TTL_PRIVACY".localized)
        
        navigaitonItem.navigationController = self.navigationController as? IGNavigationController

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let htmlString = "<font face='IRANSans' size='3'>" + "<p style='text-align:center'>" + body + "</p>"
        print("htmlString :",htmlString)

        if SMLangUtil.loadLanguage() == "fa" {
            self.webView.loadHTMLString(htmlString.replacingOccurrences(of: "<p>", with: "<p style=\"text-align: left;\">"), baseURL: nil)
        }
        else {
            self.webView.loadHTMLString(htmlString.replacingOccurrences(of: "<p>", with: "<p style=\"text-align: left;\">"), baseURL: nil)

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
