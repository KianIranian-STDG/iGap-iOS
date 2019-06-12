//
//  packetTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/6/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import webservice

var currentBussinessType = 3
var merchantID : String = ""
var merchantBalance : String = "0"
var currentRole = "paygearuser"

var needToUpdate = false
class packetTableViewController: BaseTableViewController , HandleDefaultCard,UICollectionViewDelegate , UICollectionViewDataSource {
    var shouldShowHisto = false
    var merchant : SMMerchant!

    @IBOutlet weak var lblWalletBalance : UILabel!
    @IBOutlet weak var lblCurrencyFormat : UILabel!
    @IBOutlet weak var lblMyHistoryTitle : UILabel!
    @IBOutlet weak var lblMyCards: UILabel!
    @IBOutlet weak var btnCashout: UIButtonX!
    @IBOutlet weak var btnHisto: UIButton!
    @IBOutlet weak var btnCharge: UIButtonX!
    var bussinessArray : [Int]! = []
    var showSection: Bool = true
    var selectedRow: Int = 0

    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var items: [[DropdownItem]]!
    var otheritems: [DropdownItem]!
    var Taxyitems: [DropdownItem] = []
    var Merchantitems: [DropdownItem] = []

    
    
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
    var merchantCard : SMCard?

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
        defaultHeightSize = Int(cardCollectionView.frame.height)
        defaultWidthSize = Int(cardCollectionView.frame.width)
        self.tableView.backgroundColor = UIColor.iGapTableViewBackground()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldShowHisto = false
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        callRefreshToken()
        finishDefault(isPaygear: true, isCard: false)
        initCollectionView()
        currentRole = "paygearuser"

       self.setupUI()
        self.view.layoutIfNeeded()
        self.btnCharge.layoutIfNeeded()
       SMCard.updateBaseInfoFromServer()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        merchantID = SMUserManager.accountId
        getMerchantData()
        initChangeLanguage()
        IGRequestWalletGetAccessToken.sendRequest()
        
    }
    
    //MARK: change Language Handler
    func initChangeLanguage() {
        //        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        lblWalletBalance.text = SMLangUtil.changeLblText(tag: lblWalletBalance.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblMyCards.text = SMLangUtil.changeLblText(tag: lblMyCards.tag, parentViewController: NSStringFromClass(self.classForCoder))
        lblCurrencyFormat.text = SMLangUtil.changeLblText(tag: lblCurrencyFormat.tag, parentViewController: NSStringFromClass(self.classForCoder))
        btnCashout.setTitle(SMLangUtil.changeLblText(tag: btnCashout.tag, parentViewController: NSStringFromClass(self.classForCoder)), for: .normal)
        btnCharge.setTitle(SMLangUtil.changeLblText(tag: btnCharge.tag, parentViewController: NSStringFromClass(self.classForCoder)), for: .normal)
        lblMyHistoryTitle.text = "MONEY_TRANSFER_HISTORY".localizedNew

        
        }
    func initView() {
        

        hasShownQrCode = false
        let settingItem = UIBarButtonItem.init(image: UIImage(named: "settings"), style: .done, target: self, action: #selector(showSetting))
        let receiverItem = UIBarButtonItem.init(image: UIImage(named: "store"), style: .done, target: self, action: #selector(showReceivers))
        if userMerchants?.count != nil {
            if (userMerchants?.count)! > 1  {
                
                if currentRole == "admin" || currentRole == "paygearuser" {
                    self.navigationItem.rightBarButtonItems = [settingItem , receiverItem]
                }
                else {
                    self.navigationItem.rightBarButtonItems = [receiverItem]
                    
                }
            }
            else {
                self.navigationItem.rightBarButtonItems = [settingItem]
                
            }
        }



    }
    func setupUI() {
        switch currentRole {
        case "paygearuser" :
            self.btnCharge.isHidden = false
            self.btnCashout.isHidden = false
            self.btnHisto.isHidden = false
            self.lblWalletBalance.text = "TTL_WALLET_BALANCE_USER".localizedNew
            self.btnCashout.setTitle("BTN_CASHOUT_WALLET".localizedNew, for: .normal)
            initView()
            self.view.layoutIfNeeded()

            break
        case "admin" :
            self.btnCharge.isHidden = true
            self.btnCashout.isHidden = false
            self.btnHisto.isHidden = true
            if currentBussinessType == 0 {
                self.lblWalletBalance.text = "TTL_WALLET_BALANCE_STORE".localizedNew
                self.btnCashout.setTitle("BTN_CASHOUT_WALLET_STORE".localizedNew, for: .normal)
            }
            if currentBussinessType == 2 {
                self.btnCashout.setTitle("BTN_CASHOUT_WALLET_DRIVER".localizedNew, for: .normal)
                self.lblWalletBalance.text = "TTL_WALLET_BALANCE_DRIVER".localizedNew

            }
            initView()
            self.view.layoutIfNeeded()
            break
        case "finance" :
            self.btnCharge.isHidden = true
            self.btnCashout.isHidden = true
            self.btnHisto.isHidden = true
            if currentBussinessType == 0 {
                self.lblWalletBalance.text = "TTL_WALLET_BALANCE_STORE".localizedNew
                self.btnCashout.setTitle("BTN_CASHOUT_WALLET_STORE".localizedNew, for: .normal)
            }
            if currentBussinessType == 2 {
                self.btnCashout.setTitle("BTN_CASHOUT_WALLET_DRIVER".localizedNew, for: .normal)
                self.lblWalletBalance.text = "TTL_WALLET_BALANCE_DRIVER".localizedNew
                
            }
            initView()
            self.view.layoutIfNeeded()

            break
        default :
            break
        }
    }
    func initTableView() {
        
    }
    
    func getMerchantData() {
        
        SMMerchant.getAllMerchantsFromServer(SMUserManager.accountId, { (response) in
            
            self.userMerchants = SMMerchant.getAllMerchantsFromDB()
            self.initView()
        }) { (error) in
            //
        }
    }
    
    
    
    @objc func showSetting(){
        
        let walletSettingPage : IGWalletSettingTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "walletSettingPage") as! IGWalletSettingTableViewController)
        self.navigationController!.pushViewController(walletSettingPage!, animated: true)
        
    }
    
    @objc func showReceivers(){
        bussinessArray.removeAll()
        Merchantitems.removeAll()
        Taxyitems.removeAll()
        var menuView: DropdownMenu?
        menuView?.layer.cornerRadius = 15.0
        menuView?.clipsToBounds = true

        
        for i in 0..<userMerchants!.count {
            bussinessArray.append(userMerchants![i].businessType ?? 3)
        }
        bussinessArray = uniq(source: bussinessArray)
        for ii in userMerchants! {
            if let tmpVal : Int = ii.businessType {
                switch tmpVal {
                case 0 :
                    currentBussinessType = 0
                    let tmpItem = DropdownItem(image: nil, title: "\((ii.name)!) - \((ii.role!).localizedNew)", id: (ii.id!), role: (ii.role!), bType: (ii.businessType!))
                    Merchantitems.append(tmpItem)
                    break
                case 1 :
                    break
                case 2 :
                    let tmpItem = DropdownItem(image: nil, title: "\((ii.name)!) - \((ii.role!).localizedNew)", id: (ii.id!), role: (ii.role!), bType: (ii.businessType!))
                    Taxyitems.append(tmpItem)

                    break
                default :
                    break
                }
            }

        }
        if showSection {
            switch bussinessArray.count {
            case 1 :
                let item0 = DropdownItem(image: nil, title: "paygearuser".localizedNew, id: SMUserManager.accountId, role: ("paygearuser"), bType: 3)
                let section0 = DropdownSection(sectionIdentifier:  "", items: [item0])
                items = [[item0]]
                menuView = DropdownMenu(navigationController: navigationController!, sections: [section0], selectedIndexPath: selectedIndexPath)
                break
            case 2 :

                if bussinessArray.contains(0) {
                    let item0 = DropdownItem(image: nil, title: "paygearuser".localizedNew, id: SMUserManager.accountId, role: ("paygearuser"), bType: 3)
                    let section0 = DropdownSection(sectionIdentifier:  "", items: [item0])

                    let section1 = DropdownSection(sectionIdentifier:  "store".localizedNew, items: Merchantitems)

               
                    
                    items = [[item0],Merchantitems]
                    menuView = DropdownMenu(navigationController: navigationController!, sections: [section0,section1], selectedIndexPath: selectedIndexPath)

                }
                
                else if bussinessArray.contains(2) {
                    let item0 = DropdownItem(image: nil, title: "paygearuser".localizedNew, id: SMUserManager.accountId, role: ("paygearuser"), bType: 3)
                    let section0 = DropdownSection(sectionIdentifier:  "", items: [item0])
                    
                    let section1 = DropdownSection(sectionIdentifier:  "driver".localizedNew, items: Taxyitems)
                    
                    
                    
                    items = [[item0],Taxyitems]
                    menuView = DropdownMenu(navigationController: navigationController!, sections: [section0,section1], selectedIndexPath: selectedIndexPath)
                    
                }

                
                break
            case 3 :
                if bussinessArray.contains(0) {
                    let item0 = DropdownItem(image: nil, title: "paygearuser".localizedNew, id: SMUserManager.accountId, role: ("paygearuser"), bType: 3)
                    let section0 = DropdownSection(sectionIdentifier:  "", items: [item0])
                    
                    let section1 = DropdownSection(sectionIdentifier:  "store".localizedNew, items: Merchantitems)
                    let section2 = DropdownSection(sectionIdentifier:  "driver".localizedNew, items: Taxyitems)

                    
                    
                    items = [[item0],Merchantitems ,Taxyitems]
                    menuView = DropdownMenu(navigationController: navigationController!, sections: [section0,section1 ,section2], selectedIndexPath: selectedIndexPath)
                    
                }
                break
            case 4 :
                break
            default :
                break
            }
            
        }
        menuView?.textFont = UIFont.igFont(ofSize: 15)
        menuView?.sectionHeaderStyle.font = UIFont.igFont(ofSize: 15)
        
        //menuView?.separatorStyle = .none
        menuView?.zeroInsetSeperatorIndexPaths = [IndexPath(row: 1, section: 0)]
        menuView?.delegate = self
        menuView?.rowHeight = 50
        
        menuView?.showMenu()
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
        return 5
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
        merchantBalance = (lblCurrency.text!).inEnglishNumbers()
        self.navigationController!.pushViewController(qrVC!, animated: true)
        
    }
    @IBAction func btnGoToHistory(_ sender: Any) {
        let historyVC: SMHistoryTableViewController? = (storyboard?.instantiateViewController(withIdentifier: "historytable") as! SMHistoryTableViewController)
        historyVC?.isInStandardHistoPage = true
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
                    print(lblCurrency.text)
                    if (lblCurrency.text)?.inEnglishNumbers() == "0" {
                        btnCashout.isEnabled = false
                        btnCashout.backgroundColor = .iGapGray()
                        btnCharge.backgroundColor = .iGapGreen()
                        btnCashout.isUserInteractionEnabled = false
                    }
                    else {
                        btnCashout.isEnabled = true
                        btnCashout.backgroundColor = .iGapGreen()
                        btnCharge.backgroundColor = .iGapGreen()
                        btnCashout.isUserInteractionEnabled = true

                    }

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
            if shouldShowHisto {
                return 0
            }
            else {
                if !hasValue {
                    return CGFloat(1 * (defaultHeightSize))
                }
                else {
                    return CGFloat((CGFloat((self.userCards?.count)!) * CGFloat(defaultHeightSize) - (CGFloat((self.userCards?.count)! - 1) * CGFloat(100))))
                    
                }
            }
            
        }
        else if indexPath.item == 0 {
            return 331
        }
        else if indexPath.item == 1 {
            if shouldShowHisto {
                return 0

            }
            else {
                return 57

            }
        }
        else if indexPath.item == 3 {
            if shouldShowHisto {
            return 57
            }
            else {
                return 0

            }
        }
        else if indexPath.item == 4 {
            if shouldShowHisto {
                return 331
            }
            else {
                return 0

            }
            
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
            cell.imgBackground.downloadedFrom(link: stringImgArray[indexPath.item] , cashable: true, contentMode: .scaleToFill, completion: {_ in
            })
            cell.lblCardNum.text = self.stringCardNumArray[indexPath.item].addSepratorforCardNum().inLocalizedLanguage()
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

        let cellSize = CGSize(width:((UIScreen.main.bounds.width) - 40) , height: CGFloat(heideghtSize))
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)

        layout.itemSize = cellSize
        
        cardCollectionView.collectionViewLayout = layout
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    //MARK:- MERCHANTS SERVICES
    func getMerChantCards(){
        SMLoading.showLoadingPage(viewcontroller: self)
        lblCurrency.text = "Updating ...".localizedNew

        DispatchQueue.main.async {
            SMCard.getMerchatnCardsFromServer(accountId: merchantID, { (value) in
                if let card = value {
                    self.merchantCard = card as? SMCard
                    self.prepareMerChantCard()
                }
            }, onFailed: { (value) in
                // think about it
            })
        }
    }
    
    func prepareMerChantCard() {
        SMLoading.hideLoadingPage()
        if let card = merchantCard {
            if card.type == 1 {
//                amountLbl.isHidden = false
                lblCurrency.text = String.init(describing: card.balance ?? 0).inRialFormat().inLocalizedLanguage()
                let tmp = lblCurrency.text
                if tmp?.inEnglishNumbers() == "0" {
                    btnCashout.isEnabled = false
                    btnCashout.backgroundColor = .iGapGray()
                    btnCharge.backgroundColor = .iGapGreen()

                    btnCashout.isUserInteractionEnabled = false
                }
                else {
                    btnCashout.isEnabled = true
                    btnCashout.backgroundColor = .iGapGreen()
                    btnCharge.backgroundColor = .iGapGreen()
                    btnCashout.isUserInteractionEnabled = true


                }
                NotificationCenter.default.post(name: Notification.Name(SMConstants.notificationHistoryMerchantUpdate), object: nil,
                                                userInfo: ["id": merchantID])

            }
        }
    }

}

extension packetTableViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        print(indexPath.row)
        print("||||||||INDEX")

        switch indexPath.section {
        case 0 :
            shouldShowHisto = false
            currentBussinessType = 3
            merchantID = SMUserManager.accountId
            currentRole = "paygearuser"
            self.tableView.beginUpdates()
            setupUI()
            finishDefault(isPaygear: true, isCard: false)
            isMerchant = false

            self.tableView.endUpdates()
            break
        case 1 :
            
            
            shouldShowHisto = true
            self.tableView.beginUpdates()
            currentBussinessType = items[indexPath.section][indexPath.row].bType ?? 0
            merchantID = items[indexPath.section][indexPath.row].id

            currentRole = items[indexPath.section][indexPath.row].role
            setupUI()
            getMerChantCards()
            isMerchant = true

            self.tableView.endUpdates()

            break
        case 2 :
            shouldShowHisto = true
            self.tableView.beginUpdates()
            merchantID = items[indexPath.section][indexPath.row].id
            currentBussinessType = items[indexPath.section][indexPath.row].bType ?? 2
            currentRole = items[indexPath.section][indexPath.row].role
            setupUI()
            getMerChantCards()
            isMerchant = true

            self.tableView.endUpdates()

            break
        default :
            break
        }
        print("||||||||INDEX2")
        print(merchantID)
        print("||||||||INDEX2")

        
    }
    
}
func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    var buffer = [T]()
    var added = Set<T>()
    for elem in source {
        if !added.contains(elem) {
            buffer.append(elem)
            added.insert(elem)
        }
    }
    return buffer
}

