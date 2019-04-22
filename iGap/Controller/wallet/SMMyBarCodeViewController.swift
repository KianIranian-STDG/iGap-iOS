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


/// This class generate QR code of user by its id and shows it in a image view
class SMMyBarCodeViewController: UIViewController {

    var realm = try! Realm()

    @IBOutlet var barcodeImageView: UIImageView!
    @IBOutlet var infoLbl: UILabel!
    /// The wallet amount of user

    /// If the merchant QR code is selected, this variable has value.
    /// In normal user page, this value is null
//    var merchant : SMMerchant?
    
    private var accountId = ""
    private var accountType : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        initNavigationBar()
        // Do any additional setup after loading the view.
        
//        if merchant == nil {
//            accountType = SMQRCode.SMAccountType.User.rawValue
//        }
//        else {
//
            accountType = SMQRCode.SMAccountType.User.rawValue
        
        if let sessionInfo = realm.objects(IGSessionInfo.self).first {
            if sessionInfo.loginToken != nil {
                fillUserInfo(sessionInfo: sessionInfo)

            }
        }
//        }
        
        getBarcode()
        infoLbl.text = "Show this QR to others so they scan and pay money to you."
        
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
        
        self.navigationController!.navigationBar.topItem!.title = "My QR"
        
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
//        string.append("\"")
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
