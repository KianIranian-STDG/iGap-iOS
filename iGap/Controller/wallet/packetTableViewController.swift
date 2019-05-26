//
//  packetTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice

var needToUpdate = false
class packetTableViewController: BaseTableViewController , HandleDefaultCard,UICollectionViewDelegate , UICollectionViewDataSource {
    
    @IBOutlet weak var lblWalletBalance : UILabel!
    @IBOutlet weak var lblCurrencyFormat : UILabel!
    @IBOutlet weak var lblMyCards: UILabel!
    @IBOutlet weak var btnCashout: UIButtonX!
    @IBOutlet weak var btnCharge: UIButtonX!
    
    
    
    
    var cellHeight : Int = 270
    var StaticCellHeight : Int = 130
    var plusValue : Int = 0
    var hasValue = false
    var bank = SMBank()
    var defaultHeightSize : Int = 0
    var defaultWidthSize : Int = 0
    @IBOutlet weak var cardCollectionView: UICollectionView!
    func valueChanged(value: Bool) {
        
    }
    
    
    @IBOutlet weak var lblCurrency: UILabel!
    
    var userCards: [SMCard]?
    //array for holding background of cards
    var stringImgArray = [String]()
    //array for holding cardnum of cards
    var stringCardNumArray = [String]()

    //array for holding logo of banks of cards
    var stringBankCodeArray = [Int64]()
    var stringBankLogoArray = [String]()
    var stringBankNameArray = [String]()
    var stringCardTokenArray = [String]()
    var stringCardTypeArray = [Int64]()
    var stringCardisDefaultArray = [Bool]()

    var userMerchants: [SMMerchant]?

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initView()
        defaultHeightSize = Int(cardCollectionView.frame.height)
        defaultWidthSize = Int(cardCollectionView.frame.width)
        self.tableView.backgroundColor = UIColor.iGapTableViewBackground()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        callRefreshToken()
        finishDefault(isPaygear: true, isCard: false)
        initCollectionView()
        
       SMCard.updateBaseInfoFromServer()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChangeLanguage()
    }
    
    //MARK: change Language Handler
    func initChangeLanguage() {
        //        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        lblWalletBalance.text = SMLangUtil.changeLblText(tag: lblWalletBalance.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblMyCards.text = SMLangUtil.changeLblText(tag: lblMyCards.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblCurrencyFormat.text = SMLangUtil.changeLblText(tag: lblCurrencyFormat.tag, parentViewController: NSStringFromClass(self.classForCoder))
        btnCashout.setTitle(SMLangUtil.changeLblText(tag: btnCashout.tag, parentViewController: NSStringFromClass(self.classForCoder)), for: .normal)
        btnCharge.setTitle(SMLangUtil.changeLblText(tag: btnCharge.tag, parentViewController: NSStringFromClass(self.classForCoder)), for: .normal)

        
        }
    func initView() {
        


        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "settings"), style: .done, target: self, action: #selector(showSetting))

        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    func initTableView() {
        
    }
    
    
    @objc func showSetting(){
        
        let walletSettingPage : IGWalletSettingTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
        self.navigationController!.pushViewController(walletSettingPage!, animated: true)
        
    }
    // MARK : - init View elements
    func initNavigationBar(){
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: "SETTING_PAGE_WALLET".localizedNew)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    @IBAction func btnGoToCashInTap(_ sender: Any) {
        let cashinVC : chargeWalletTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "cashinVC") as! chargeWalletTableViewController)
        cashinVC!.balance = lblCurrency.text!
        cashinVC!.finishDelegate = self
        self.navigationController!.pushViewController(cashinVC!, animated: true)
        
    }
    @IBAction func btnGoToCashOutTap(_ sender: Any) {
        let cashoutVC : chashoutCardTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "cashoutVC") as! chashoutCardTableViewController)
        cashoutVC!.balance = lblCurrency.text!
        cashoutVC!.finishDelegate = self
        self.navigationController!.pushViewController(cashoutVC!, animated: true)
        
    }
    @IBAction func btnQRcodeScan(_ sender: Any) {
        let qrVC: QRMainTabbarController? = (storyboard?.instantiateViewController(withIdentifier: "qrMainTabbar") as! QRMainTabbarController)
        
        self.navigationController!.pushViewController(qrVC!, animated: true)
        
    }
    @IBAction func btnGoToHistory(_ sender: Any) {
        let historyVC: SMHistoryTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "historytable") as! SMHistoryTableViewController)
        self.navigationController!.pushViewController(historyVC!, animated: true)
        
    }
    func callRefreshToken() {
        SMUserManager.refreshToken(delegate: self, onSuccess: { (response) in
            
        }, onFail: { (response) in
            NSLog("%@", "FailedHandler")
        })
    }
    
    func initCardView () {
        
    }
    func finishDefault(isPaygear: Bool? ,isCard : Bool?) {
      

        SMLoading.showLoadingPage(viewcontroller: self)

        if isCard! == false && isPaygear == true {
//            paygearAmountLoading.isHidden = false
            if needToUpdate {
                lblCurrency.text = "Updating ...".localizedNew

            }
            else {
                lblCurrency.text = "..."

            }
//                startAnimating()
        }
        else {
            if needToUpdate {
                lblCurrency.text = "Updating ...".localizedNew
                
            }
            else {
                lblCurrency.text = "..."
                
            }        }

        SMCard.getAllCardsFromServer({ cards in
            if cards != nil{
                if (cards as? [SMCard]) != nil{
                    if (cards as! [SMCard]).count > 0 {
//                        self.walletView.dismissPresentedCardView(animated: true)
//                        self.walletHeaderView.alpha = 1.0
                        self.userCards = SMCard.getAllCardsFromDB()
                        self.hasValue = true
                        
                        if self.hasValue  {
                            if (self.userCards?.count)! > 1 {
                                
                                _ = Array((self.userCards?.dropFirst())!)

                                self.stringImgArray.removeAll()
                                self.stringCardNumArray.removeAll()
                                self.stringBankCodeArray.removeAll()
                                self.stringBankNameArray.removeAll()
                                self.stringBankLogoArray.removeAll()
                                self.stringCardTypeArray.removeAll()
                                self.stringCardTokenArray.removeAll()
                                self.stringCardisDefaultArray.removeAll()
                                for element in self.userCards! {
                                    if element.type != 1 {
                                        if let back : String = (element.backgroundimage!)  {
                                        let request = WS_methods(delegate: self, failedDialog: true)
                                        let str = request.fs_getFileURL(back)
                                        self.stringImgArray.append(str!)
                                  
                                    }
                                        if let tmpCardNum : String = (element.pan) {
                                            self.stringCardNumArray.append(tmpCardNum)
                                            
                                        }
                                        if let tmpBankCode : Int64 = (element.bankCode) {
                                            self.stringBankCodeArray.append(tmpBankCode)
                                            
                                        }
                                        if let tmpcardToken : String = (element.token) {
                                            self.stringCardTokenArray.append(tmpcardToken)
                                            
                                        }
                                        if let tmpCardType : Int64 = (element.type) {
                                            self.stringCardTypeArray.append(tmpCardType)
                                            
                                        }
                                        if let tmpIsDefaultState : Bool = (element.isDefault) {
                                            self.stringCardisDefaultArray.append(tmpIsDefaultState)
                                        }
                                        self.getBankInfo()
                                        
                                    }
                                }
                                
                                self.plusValue = ((self.userCards?.count)! - 2 ) * 100
                                
                                
                            }
                            else {
                                self.plusValue = 0
                            }
                        }
                        self.cardCollectionView.reloadData()
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                        if   isPaygear!{
                            self.preparePayGearCard()
                        }
                        if isCard!{
                            
                        }
                        

                    }
                }
            }
            needToUpdate = true
        }, onFailed: {err in
//            SMLoading.showToast(viewcontroller: self, text: "serverDown".localized)
        })
    }
    
    func preparePayGearCard(){

        if let cards = userCards {
            for card in cards {
                
                if card.type == 1{
                    
                    lblCurrency.text = String.init(describing: card.balance ?? 0).inRialFormat().inLocalizedLanguage()
                    SMUserManager.payGearToken = card.token
                    SMUserManager.isProtected = card.protected
                    SMUserManager.userBalance = card.balance

                    if ((card.balance ?? 0) - (card.cashablebalance ?? 0)) == 0 {

                        
                    }
                    else{

                    }
                }
            }
        }
    }
    //Mark : UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.item == 2 {
            if !hasValue {
                return CGFloat(1 * (defaultHeightSize))
            }
            else {
                print(CGFloat(CGFloat((self.userCards?.count)!) * CGFloat(defaultHeightSize)))
                return CGFloat((CGFloat((self.userCards?.count)!) * CGFloat(defaultHeightSize) - (CGFloat((self.userCards?.count)! - 1) * CGFloat(100))))

            }
        }
        else if indexPath.item == 0 {
            return 331
        }
        else if indexPath.item == 1 {
            return 57
        }
        else {
            return 57
        }
    }

    //Mark : UIcollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !hasValue {
            return 0
        }
        else {
            if (self.userCards?.count)! > 1 {
            return ((userCards?.count)! - 1)
            }
            else {
                return 0
            }
        }
     
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardsCollectionViewCell", for: indexPath) as! CardsCollectionViewCell
        if hasValue {
            print(stringImgArray[indexPath.row])
            cell.imgBackground.downloadedFrom(link: stringImgArray[indexPath.item] , cashable: true, contentMode: .scaleToFill, completion: {_ in
                print(link)

            })
//            cell.imgBackground.layer.cornerRadius = 15.0
            cell.lblCardNum.text = self.stringCardNumArray[indexPath.item].addSepratorforCardNum()
            cell.lblBankName.text = self.stringBankNameArray[indexPath.item]
            cell.imgBankLogo.image = UIImage(named: self.stringBankLogoArray[indexPath.item])
            
        

          


        }
        return cell
        
    }
    func getBankInfo() {
        self.stringBankNameArray.removeAll()
        self.stringBankLogoArray.removeAll()
        for element in self.stringBankCodeArray {
            bank.setBankInfo(code: element)
            stringBankLogoArray.append(bank.logoRes!)
            stringBankNameArray.append(bank.nameFA!)
            
        }
    }
    
    func initCollectionView() {
        let layout = cardCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 10
        
        let heideghtSize = ((defaultWidthSize) / 2 )
        layout.minimumLineSpacing =  CGFloat((Double(heideghtSize) / 1.5) * -1)

        print(cardCollectionView.frame.width)
        print(cardCollectionView.frame.height)
        print(UIScreen.main.bounds.width)
        print(UIScreen.main.bounds.height)
        let cellSize = CGSize(width:((UIScreen.main.bounds.width) - 40) , height: CGFloat(heideghtSize))
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

        layout.itemSize = cellSize
        
        cardCollectionView.collectionViewLayout = layout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
        
        let cardDetailVC : IGWalletCardDetailTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "IGWalletCardDetail") as! IGWalletCardDetailTableViewController)
      
        cardDetailVC!.logoString = self.stringBankLogoArray[indexPath.item]
        cardDetailVC!.urlBack = self.stringImgArray[indexPath.item]
        cardDetailVC?.cardNum = self.stringCardNumArray[indexPath.item].addSepratorforCardNum()
        cardDetailVC?.cardToken = self.stringCardTokenArray[indexPath.item]
        cardDetailVC?.cardDefault = self.stringCardisDefaultArray[indexPath.item]

        let topIndex = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topIndex, at: .top, animated: true)
        self.navigationController!.pushViewController(cardDetailVC!, animated: true)
    }
}
