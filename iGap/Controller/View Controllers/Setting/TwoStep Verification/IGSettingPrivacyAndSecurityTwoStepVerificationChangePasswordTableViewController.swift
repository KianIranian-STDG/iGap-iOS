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
import SwiftProtobuf
import IGProtoBuff
import MBProgressHUD

class IGSettingPrivacyAndSecurityTwoStepVerificationChangePasswordTableViewController: BaseTableViewController {

    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyTextField: UITextField!
    @IBOutlet weak var lblVerify: UILabel!
    @IBOutlet weak var lblPass: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblPass.text = "SETTING_PS_TV_PASSWORD".localizedNew
        lblVerify.text = "SETTING_PS_TV_VERIFY_PASSWORD".localizedNew
    }
    
}
