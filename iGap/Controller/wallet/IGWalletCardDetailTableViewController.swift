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

class IGWalletCardDetailTableViewController: BaseTableViewController {

    @IBOutlet weak var lblCardNum : UILabel!
    @IBOutlet weak var imgBankLogo : UIImageView!
    @IBOutlet weak var imgBackgroundCard : UIImageView!
    @IBOutlet weak var switchDefaultCard : UISwitch!
    @IBOutlet weak var lblCardDefaultTitle : UILabel!
    @IBOutlet weak var btnRemove : UIButton!
    @IBOutlet weak var btnAmount : UIButton!
    @IBOutlet weak var lblBankName: UILabel!
    var cardType : Int64!
    var cardNum : String!
    var logoString : String!
    var urlBack : String!
    var cardToken : String!
    var cardDefault : Bool!
    var amount : String!
    var bankName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblCardDefaultTitle.text = "TTL_SET_AS_DEFAULT_CARD".localizedNew
        btnRemove.setTitle("DELETE_CARD".localizedNew, for: .normal)
    }
    func initView() {
        self.btnAmount.setTitle(amount.inRialFormat() + " " + "CURRENCY".localizedNew, for: .normal)
        
        imgBankLogo.image = UIImage(named: logoString)
        imgBackgroundCard.downloadedFrom(link: urlBack , cashable: true, contentMode: .scaleToFill, completion: {_ in
            print(link)
        })
        lblCardNum.font = UIFont.igFont(ofSize: 20 , weight: .bold)
        
        if cardType == 1 {
            self.initNavigationBar(title: cardNum, rightItemText: "", iGapFont: true) {
                let qrVC: QRMainTabbarController = (self.storyboard?.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
                
                qrVC.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(qrVC, animated: true)
            }
            self.lblBankName.text = amount.inRialFormat() + " " + "CURRENCY".localizedNew
            lblCardNum.text = ""
        } else {
            self.initNavigationBar(title: bankName, rightItemText: "", iGapFont: true) {
                let qrVC: QRMainTabbarController = (self.storyboard?.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
                
                qrVC.hidesBottomBarWhenPushed = true
                self.navigationController!.pushViewController(qrVC, animated: true)
            }
            self.lblBankName.text = ""
            lblCardNum.text = cardNum
        }
        switchDefaultCard.setOn(cardDefault, animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBAction func btnRemoveTap(_ sender: Any) {
        SMLoading.showLoadingPage(viewcontroller: self)

        SMCard.deleteCardFromServer(cardToken, onSuccess: {
            self.navigationController?.popViewController(animated: true)
           
        }, onFailed: { err in
            
            if SMValidation.showConnectionErrorToast(err) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
            }
        })
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 :
          
            return 220
        case 1 :
            if cardType == 1 {
                return 0
            }
            else {
                return 44
                
            }
        case 2 :
            if cardType == 1 {
                return 0
            }
            else {
                return 44
            }
        case 3 :
            if cardType == 1 {
                return 44
            }
            else {
                return 0
            }
            break
        default :
            return 44

        }

    }
    @IBAction func segchanged(_ sender: Any) {
        SMCard.defaultCardFromServer(self.cardToken,isDefault: "\((sender as! UISwitch).isOn)", onSuccess: {
            SMLoading.showLoadingPage(viewcontroller: self)
        }, onFailed: {err in
            
            if SMValidation.showConnectionErrorToast(err) {
                SMLoading.showToast(viewcontroller: self, text: "SERVER_DOWN".localizedNew)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {

            })
            
        })
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
