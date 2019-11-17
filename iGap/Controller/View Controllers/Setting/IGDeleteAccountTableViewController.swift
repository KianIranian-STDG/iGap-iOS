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

class IGDeleteAccountTableViewController: UITableViewController , UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lblHeader: IGLabel!
    @IBOutlet weak var lblTitle1: IGLabel!
    @IBOutlet weak var lblSub1: IGLabel!
    @IBOutlet weak var lblSub2: IGLabel!
    @IBOutlet weak var lblSub3: IGLabel!
    @IBOutlet weak var lblBtn: IGLabel!
    var hud = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        tableView.tableFooterView = UIView()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil , title: "SETTING_PAGE_ACCOUNT_D_ACCOUNT".localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self

    }
    override func viewDidAppear(_ animated: Bool) {
        hud.hide(animated: true)
        self.tableView.isUserInteractionEnabled = true

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblBtn.text = "SETTING_PAGE_ACCOUNT_D_ACCOUNT".localized
        
        lblSub1.text = "DELETE_SUB1".localized
        lblSub2.text = "DELETE_SUB2".localized
        lblSub3.text = "DELETE_SUB3".localized

        lblTitle1.text = "DELETE_TITLE".localized
        lblHeader.text = "SURE_DELETE".localized
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isUserInteractionEnabled = false
        getDeleteToken()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        func getDeleteToken(){
        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.hud.mode = .indeterminate
        IGUserGetDeleteTokenRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getDeleteTokenProtoResponse as IGPUserGetDeleteTokenResponse:
                    let _ = IGUserGetDeleteTokenRequest.Handler.interpret(response: getDeleteTokenProtoResponse)
                    self.hud.hide(animated: true)
                    self.performSegue(withIdentifier: "GoToConfirmDeletePage", sender: self)
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localized, message: "MSG_PLEASE_TRY_AGAIN".localized, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: IGStringsManager.GlobalOK.rawValue.localized, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            case .userGetDeleteTokenLockedManyTries:
                DispatchQueue.main.async {
                    
                    let remainingSeconds = waitTime!%60
                    let remainingMiuntes = waitTime!/60
                    let alert = UIAlertController(title: "Blocked User", message: "you account is blocked, try again in \(remainingMiuntes):\(remainingSeconds)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.hud.hide(animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
                default:
                break
            }
            
        }).send()
        
    }
    
}
