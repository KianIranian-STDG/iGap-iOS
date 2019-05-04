/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the RooyeKhat Media Company - www.RooyeKhat.co
 * All rights reserved.
 */

import UIKit
import RealmSwift
import IGProtoBuff

class IGAccountViewController: BaseTableViewController , UINavigationControllerDelegate , UIGestureRecognizerDelegate  {
    
    @IBOutlet weak var emailIndicator: UIActivityIndicatorView!
    @IBOutlet weak var phoneNumberEntryLabel: UILabel!
    @IBOutlet weak var nicknameEntryLabel: UILabel!
    @IBOutlet weak var usernameEntryLabel: UILabel!
    @IBOutlet weak var emailEntryLabel: UILabel!
    @IBOutlet weak var lblIgapGlubal: UILabel!
    @IBOutlet weak var selfDestructionLabel: UILabel!
    @IBOutlet weak var bioEntryLabel: IGLabel!
    @IBOutlet weak var bioIndicator: UIActivityIndicatorView!
    @IBOutlet weak var representerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var representerLabel: IGLabel!
    @IBOutlet weak var scoreLabel: IGLabel!
    @IBOutlet weak var scoreIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblNikname: UILabel!
    @IBOutlet weak var lblPhoneNUmber: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblRefferal: UILabel!
    @IBOutlet weak var lblDeleteAccount: UILabel!
    @IBOutlet weak var lblSelfDestruction: UILabel!
    @IBOutlet weak var lblSelfDestructionHint: UILabel!
    @IBOutlet weak var lblLogOut: UILabel!

    
    var allowSetRepresentative = false
    var currentUser: IGRegisteredUser!
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ACCOUNT_VIEW".localizedNew
        self.tableView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        showAccountDetail()
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "ACCOUNT_VIEW".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.isUserInteractionEnabled = true
        changeBackButtonItemPosition()
        if currentUser.email == nil {
            getUserEmail()
        } else {
            self.emailIndicator.stopAnimating()
            self.emailIndicator.hidesWhenStopped = true
        }
        
        if currentUser.bio == nil {
            getUserBio()
        } else {
            self.bioIndicator.stopAnimating()
            self.bioIndicator.hidesWhenStopped = true
        }
        
        if let representer = IGSessionInfo.getRepresenter(), !representer.isEmpty {
            self.allowSetRepresentative = false
            self.representerLabel.text = representer
            self.representerIndicator.stopAnimating()
            self.representerIndicator.hidesWhenStopped = true
        } else {
            getRepresenter()
        }
        
        getScore()
        
        if currentUser.selfRemove == -1 {
            getSelfRemove()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLanguage()
    }
    //MARK: change Language Handler
    func initChangeLanguage() {
//        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        lblIgapGlubal.text = "SETTING_PAGE_ACCOUNT_IGAP_CLUB".localizedNew
        lblNikname.text = SMLangUtil.changeLblText(tag: lblNikname.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblPhoneNUmber.text = SMLangUtil.changeLblText(tag: lblPhoneNUmber.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblUserName.text = SMLangUtil.changeLblText(tag: lblUserName.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblEmail.text = SMLangUtil.changeLblText(tag: lblEmail.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblBio.text = SMLangUtil.changeLblText(tag: lblBio.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblRefferal.text = SMLangUtil.changeLblText(tag: lblRefferal.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblDeleteAccount.text = SMLangUtil.changeLblText(tag: lblDeleteAccount.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblSelfDestruction.text = SMLangUtil.changeLblText(tag: lblSelfDestruction.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblSelfDestructionHint.text = SMLangUtil.changeLblText(tag: lblSelfDestructionHint.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblLogOut.text = SMLangUtil.changeLblText(tag: lblLogOut.tag, parentViewController: NSStringFromClass(self.classForCoder))
        

    }

    //MARK: Account details
    func showAccountDetail(){
        let currentUserId = IGAppManager.sharedManager.userID()
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", currentUserId!)
        currentUser = realm.objects(IGRegisteredUser.self).filter(predicate).first!
        self.updateUI()
        notificationToken = currentUser.observe({ (changes: ObjectChange) in
            switch changes {
            case .change(_):
                self.updateUI()
            default:
                break
            }
            
        })
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.nicknameEntryLabel.text = self.currentUser.displayName
            self.usernameEntryLabel.text = self.currentUser.username
            self.emailEntryLabel.text = self.currentUser.email
            self.phoneNumberEntryLabel.text = "\(self.currentUser.phone)"
            self.bioEntryLabel.text = self.currentUser.bio
            
            if self.currentUser.selfRemove == -1 {
                self.selfDestructionLabel.text = ""
            } else if self.currentUser.selfRemove == 12 {
                self.selfDestructionLabel.text = "1 " + "YEAR".localizedNew
            } else if self.currentUser.selfRemove == 1 {
                self.selfDestructionLabel.text = "\(self.currentUser.selfRemove)" + "MONTH".localizedNew
            } else {
                self.selfDestructionLabel.text = "\(self.currentUser.selfRemove)" + "MONTHS".localizedNew
            }
        }
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 6
        case 2 :
            return 2
        case 3 :
            return 1
            default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToNicknamePage", sender: self)
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToUsernamePage", sender: self)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToEmailPage", sender: self)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToBioPage", sender: self)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 && allowSetRepresentative {
            self.tableView.isUserInteractionEnabled = false
            let representative = IGRepresentativeViewController.instantiateFromAppStroryboard(appStoryboard: .Register)
            representative.popView = true
            self.navigationController!.pushViewController(representative, animated: true)
        }
        
        if indexPath.section == 1 && indexPath.row == 5 {
            let score = IGScoreViewController.instantiateFromAppStroryboard(appStoryboard: .Main)
            self.navigationController!.pushViewController(score, animated: true)
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToDeleteAccountPage", sender: self)
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            self.tableView.isUserInteractionEnabled = false
            performSegue(withIdentifier: "GoToSelfDestructionTimePage", sender: self)
        }
        if indexPath.section == 3 && indexPath.row == 0 {
           showLogoutActionSheet()
        }
    }
        func showLogoutActionSheet(){
            let logoutConfirmAlertView = UIAlertController(title: "SURE_LOGOUT".localizedNew , message: nil, preferredStyle: IGGlobal.detectAlertStyle())
            let logoutAction = UIAlertAction(title: "SETTING_PAGE_ACCOUNT_LOGOUT".localizedNew , style:.default , handler: {
                (alert: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.logoutAndShowRegisterViewController()
                    IGWebSocketManager.sharedManager.closeConnection()
                })

            })
            let cancelAction = UIAlertAction(title: "CANCEL_BTN".localizedNew , style:.cancel , handler: {
                (alert: UIAlertAction) -> Void in
            })
            logoutConfirmAlertView.addAction(logoutAction)
            logoutConfirmAlertView.addAction(cancelAction)
            let alertActions = logoutConfirmAlertView.actions
            for action in alertActions {
                if action.title == "SETTING_PAGE_ACCOUNT_LOGOUT".localizedNew {
                    let logoutColor = UIColor.red
                    action.setValue(logoutColor, forKey: "titleTextColor")
                }
            }
            logoutConfirmAlertView.view.tintColor = UIColor.organizationalColor()
            if let popoverController = logoutConfirmAlertView.popoverPresentationController {
                popoverController.sourceView = self.tableView
                popoverController.sourceRect = CGRect(x: self.tableView.frame.midX-self.tableView.frame.midX/2, y: self.tableView.frame.midX-self.tableView.frame.midX/2, width: self.tableView.frame.midX, height: self.tableView.frame.midY)
                popoverController.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            }
            present(logoutConfirmAlertView, animated: true, completion: nil)
    }
    
    func changeBackButtonItemPosition(){
        let customView = UIView(frame: CGRect(x: 10, y: 0, width: 100, height: 64))
        customView.backgroundColor = UIColor.red
        let backItem = UIBarButtonItem(customView: customView)
        backItem.title = "GLOBAL_BACK".localizedNew
        backItem.tintColor = UIColor.organizationalColor()
        navigationItem.backBarButtonItem = backItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selfDestructionVC = segue.destination as? IGSettingHaveCheckmarkOntheLeftTableViewController {
            selfDestructionVC.items = [1, 3, 6, 12]
            selfDestructionVC.mode = "Self-Destruction"
            selfDestructionVC.modeT = "SETTING_PAGE_ACCOUNT_S_DESTRUCT".localizedNew
            
        }
    }
    
    @IBAction func goBackToMainList(seque:UIStoryboardSegue){
        self.tableView.beginUpdates()
        showAccountDetail()
        self.tableView.endUpdates()
        
    }
    
    func getUserEmail() {
        self.emailIndicator.startAnimating()
        IGUserProfileGetEmailRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let getUserEmailResponse as IGPUserProfileGetEmailResponse:
                    let userEmail = IGUserProfileGetEmailRequest.Handler.interpret(response: getUserEmailResponse)
                    self.emailEntryLabel.text = userEmail
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "TIME_OUT_MSG_EMAIL".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getUserBio() {
        self.bioIndicator.startAnimating()
        IGUserProfileGetBioRequest.Generator.generate().success({ (protoResponse) in
            DispatchQueue.main.async {
                switch protoResponse {
                case let setBioResponse as IGPUserProfileGetBioResponse:
                    IGUserProfileGetBioRequest.Handler.interpret(response: setBioResponse)
                    self.bioEntryLabel.text = setBioResponse.igpBio
                    self.bioIndicator.stopAnimating()
                    self.bioIndicator.hidesWhenStopped = true
                default:
                    break
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "TIME_OUT_MSG_BIO".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.bioIndicator.stopAnimating()
                    self.bioIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getSelfRemove() {
        IGUserProfileGetSelfRemoveRequest.Generator.generate().success({ (protoResponse) in
            switch protoResponse {
            case let response as IGPUserProfileGetSelfRemoveResponse:
                IGUserProfileGetSelfRemoveRequest.Handler.interpret(response: response)
            default:
                break
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "TIME_OUT".localizedNew, message: "TIME_OUT_MSG_SELFD".localizedNew, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "GLOBAL_OK".localizedNew, style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.emailIndicator.stopAnimating()
                    self.emailIndicator.hidesWhenStopped = true
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
            
        }).send()
    }
    
    func getRepresenter(){
        IGUserProfileGetRepresentativeRequest.Generator.generate().success({ (protoResponse) in
            if let response = protoResponse as? IGPUserProfileGetRepresentativeResponse {
                
                if response.igpPhoneNumber.isEmpty {
                    self.allowSetRepresentative = true
                }
                IGUserProfileGetRepresentativeRequest.Handler.interpret(response: response)
                
                DispatchQueue.main.async {
                    self.representerLabel.text = response.igpPhoneNumber
                    self.representerIndicator.stopAnimating()
                    self.representerIndicator.hidesWhenStopped = true
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getRepresenter()
            default:
                DispatchQueue.main.async {
                    self.representerIndicator.stopAnimating()
                    self.representerIndicator.hidesWhenStopped = true
                }
                break
            }
        }).send()
    }
    
    func getScore(){
        IGUserIVandGetScoreRequest.Generator.generate().success({ (protoResponse) in
            if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                DispatchQueue.main.async {
                    self.scoreLabel.text = String(describing: response.igpScore).inLocalizedLanguage()
                    self.scoreIndicator.stopAnimating()
                    self.scoreIndicator.hidesWhenStopped = true
                }
            }
        }).error ({ (errorCode, waitTime) in
            switch errorCode {
            case .timeout:
                self.getScore()
            default:
                break
            }
        }).send()
    }
    
}
