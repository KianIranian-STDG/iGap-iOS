//
//  SMMyBarCodeViewController.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/22/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import webservice
import RealmSwift

/// Type of product QR code
///
/// - khati: The taxi with source and destination and defined price
/// - gardeshi: the taxi without information about places and price
/// - Ajans: private taxi
public var isMerchant = false
enum SMTransportType: Int {
    case khati = 0;
    case gardeshi = 1;
    case Ajans    = 2;
}

/// Type of Payment pop up
///
/// - PopupNoProductTaxi: The taxi pop up shows the information of taxi and driver name, no price is provided at this type, so user must enter it
/// - PopupProductedTaxi: Taxi popup with product shows the information of taxi and driver name with price, the price could be increased by unit
/// - PopupUser: User popup is normal type to show receiver name and price
enum SMAmountPopupType: Int {
    case PopupNoProductTaxi = 0
    case PopupProductedTaxi = 1
    case PopupUser          = 2
    case HyperMe            = 3
}

/// This class generate QR code of user by its id and shows it in a image view
class SMMyBarCodeViewController: UIViewController {

    
    var realm = try! Realm()

    @IBOutlet var barcodeImageView: UIImageView!
    @IBOutlet var infoLbl: UILabel!
    /// The wallet amount of user

    /// If the merchant QR code is selected, this variable has value.
    /// In normal user page, this value is null
    var merchant : SMMerchant?
    
    private var accountId = ""
    private var accountType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBarItem.title = "MY_QR"
        self.tabBarController?.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.igFont(ofSize: 10)], for: .normal)
        if !isMerchant {
            accountType = SMQRCode.SMAccountType.User.rawValue
//            if let sessionInfo = realm.objects(IGSessionInfo.self).first {
//                if sessionInfo.loginToken != nil {
//                    fillUserInfo(sessionInfo: sessionInfo)
//                }
//            }
            accountId = merchantID

        }
        else {
            accountType = SMQRCode.SMAccountType.User.rawValue
            accountId = merchantID

        }
        
        getBarcode()
        infoLbl.text = "SHOW_THIS_QR".localizedNew
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("TAB1")
        initNavigationBar()

        
    }
    private func fillUserInfo(sessionInfo: IGSessionInfo? = nil){
        
        var info : IGSessionInfo?
        if sessionInfo == nil {
            let realm = try! Realm()
            info = realm.objects(IGSessionInfo.self).first
        } else {
            info = sessionInfo
        }
        
        if info != nil {
           
            if let tmp : String = ("\((info?.userID)!)") {
                print(tmp)
                accountId = tmp ?? ""
                print(accountId)
            }
            
            
        }
    }
    
    // MARK : - init View elements
    func initNavigationBar(){
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.igFont(ofSize: 16),NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController!.navigationBar.topItem!.title = "MY_QR".localizedNew


        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    /// Create Barcode url then make QR code, then get image of QR
    func getBarcode() {
        
        var string: String = SMQRCode.URL
        string.append("{\"T\":")
        string.append("\"")
        string.append(accountType!)
        string.append("\"")
        string.append(",")
        string.append("\"H\":")
        string.append("\"")
        string.append(accountId)
        string.append("\"}")
        
        let data = string.data(using: .isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        let transform = CGAffineTransform(scaleX: 3, y: 3)
        
        if let qrcodeImage = filter?.outputImage?.transformed(by: transform) {
            barcodeImageView.image = UIImage(ciImage: qrcodeImage)
        }
    }
}
