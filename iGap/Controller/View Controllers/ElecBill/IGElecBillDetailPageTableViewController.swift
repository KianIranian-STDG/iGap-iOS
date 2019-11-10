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
import RealmSwift

class IGElecBillDetailPageTableViewController: BaseTableViewController,UIDocumentInteractionControllerDelegate {
    // MARK: - Outlets
    @IBOutlet weak var lblTTlBillNumber : UILabel!
    @IBOutlet weak var lblDataBillNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayNumber : UILabel!
    @IBOutlet weak var lblDataBillPayNumber : UILabel!
    @IBOutlet weak var lblTTlBillPayAmount : UILabel!
    @IBOutlet weak var lblDataBillPayAmount : UILabel!
    @IBOutlet weak var lblTTlBillPayDate : UILabel!
    @IBOutlet weak var lblDataBillPayDate : UILabel!
    @IBOutlet weak var btnPay : UIButton!
    @IBOutlet weak var btnDetailBranch : UIButton!
    @IBOutlet weak var btnAddToMyBills : UIButton!
    @IBOutlet weak var btnPDFofBill : UIButton!
    @IBOutlet weak var topViewHolder : UIViewX!

    @IBOutlet weak var stackHolder : UIStackView!
    @IBOutlet weak var stackOne : UIStackView!
    @IBOutlet weak var stackTwo : UIStackView!
    @IBOutlet weak var stackThree : UIStackView!
    @IBOutlet weak var stackFour : UIStackView!

    // MARK: - Variables
    var billNumber: String!
    var billTittle : String! = ""
    var payDate: String!
    var payAmount: String!
    var payNumber: String!
    var canEditBill : Bool = false
    // MARK: - View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initServices()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initNavigationBar(title: "TTL_BILL_OPERATIONS".localizedNew, rightAction: {})//set Title for Page and nav Buttons if needed

    }
    // MARK: - Development Funcs
    private func initView() {
        customiseTableView()
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
    }
    
    private func initServices() {
        if payDate == nil || payAmount == nil || payNumber == nil {
            let realm = try! Realm()
            let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
            let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

            let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
            SMLoading.showLoadingPage(viewcontroller: self)
            queryBill(userPhoneNumber: userPhoneNumber)
        }
    }
    
    private func customiseView() {
        self.topViewHolder.borderWidth = 0.5
        self.topViewHolder.layer.borderColor = UIColor(named: themeColor.labelColor.rawValue)?.cgColor
        btnDetailBranch.layer.borderColor = UIColor(named: themeColor.navigationSecondColor.rawValue)?.cgColor
        btnDetailBranch.layer.borderWidth = 2
        btnAddToMyBills.layer.borderColor = UIColor(named: themeColor.navigationSecondColor.rawValue)?.cgColor
        btnAddToMyBills.layer.borderWidth = 2
        btnPDFofBill.layer.borderColor = UIColor(named: themeColor.navigationSecondColor.rawValue)?.cgColor
        btnPDFofBill.layer.borderWidth = 2

        btnPay.layer.cornerRadius = 15
        btnDetailBranch.layer.cornerRadius = 15
        btnPDFofBill.layer.cornerRadius = 15
        btnAddToMyBills.layer.cornerRadius = 15
    }
    
    private func initFont() {
        lblTTlBillNumber.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayDate.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayAmount.font = UIFont.igFont(ofSize: 14)
        lblTTlBillPayNumber.font = UIFont.igFont(ofSize: 14)
        lblDataBillNumber.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayDate.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayAmount.font = UIFont.igFont(ofSize: 14)
        lblDataBillPayNumber.font = UIFont.igFont(ofSize: 14)
        btnPay.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnPDFofBill.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnAddToMyBills.titleLabel?.font = UIFont.igFont(ofSize: 14)
        btnDetailBranch.titleLabel?.font = UIFont.igFont(ofSize: 14)
    }
    
    private func initStrings() {
        lblTTlBillNumber.text = "BILL_ID".localizedNew
        lblTTlBillPayDate.text = "BILL_PAY_DATE".localizedNew
        lblTTlBillPayAmount.text = "BILL_PAY_AMOUNT".localizedNew
        lblTTlBillPayNumber.text = "TRANSACTIONS_HISTORY_ORDER_ID".localizedNew
        lblDataBillNumber.text = billNumber ?? "..."
        lblDataBillPayDate.text = payDate ?? "..."
        lblDataBillPayAmount.text = payAmount ?? "..."
        lblDataBillPayNumber.text = payNumber ?? "..."
        btnPay.setTitle("PU_PAYMENT".localizedNew, for: .normal)
        btnDetailBranch.setTitle("BILL_BRANCH_DETAILS".localizedNew, for: .normal)
        if canEditBill {
            btnAddToMyBills.setTitle("BILL_EDIT_MODE".localizedNew, for: .normal)
        } else {
            btnAddToMyBills.setTitle("BILL_ADD_MODE".localizedNew, for: .normal)
        }
        btnPDFofBill.setTitle("BILL_PDF_IMAGE".localizedNew, for: .normal)
    }
    
    private func initColors() {
        self.tableView.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        self.topViewHolder.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnPay.setTitleColor(.white, for: .normal)
        btnDetailBranch.setTitleColor(UIColor(named: themeColor.navigationSecondColor.rawValue), for: .normal)
        btnAddToMyBills.setTitleColor(UIColor(named: themeColor.navigationSecondColor.rawValue), for: .normal)
        btnPDFofBill.setTitleColor(UIColor(named: themeColor.navigationSecondColor.rawValue), for: .normal)
        
        btnPay.backgroundColor = UIColor(named: themeColor.navigationSecondColor.rawValue)
        btnDetailBranch.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnAddToMyBills.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        btnPDFofBill.backgroundColor = UIColor(named: themeColor.backgroundColor.rawValue)
        lblTTlBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayDate.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblTTlBillPayAmount.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayDate.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayAmount.textColor = UIColor(named: themeColor.labelColor.rawValue)
        lblDataBillPayNumber.textColor = UIColor(named: themeColor.labelColor.rawValue)

    }
    
    private func initAlignments() {
        lblTTlBillPayNumber.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillPayAmount.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillPayDate.textAlignment = lblTTlBillPayNumber.localizedNewDirection
        lblTTlBillNumber.textAlignment = lblTTlBillPayNumber.localizedNewDirection
    }
    
    private func customiseTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.semanticContentAttribute = self.semantic
        self.stackOne.semanticContentAttribute = self.semantic
        self.stackTwo.semanticContentAttribute = self.semantic
        self.stackThree.semanticContentAttribute = self.semantic
        self.stackFour.semanticContentAttribute = self.semantic
        self.stackHolder.semanticContentAttribute = self.semantic

    }

    private func validaatePhoneNUmber(phone : Int64!) -> String {
        let str = String(phone)
        if str.starts(with: "98") {
            return str.replacingOccurrences(of: "98", with: "0")
        } else if str.starts(with: "09") {
            return str
        } else {
            return str
        }
    }
    private func queryBill(userPhoneNumber: String!) {

        IGApiElectricityBill.shared.queryBill(billNumber: (billNumber.inEnglishNumbersNew()), phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {
                self.payNumber = response?.data?.paymentIdentifier
                self.payDate = response?.data?.paymentDeadLine
                self.payAmount = response?.data?.totalBillDebt
                let dateFormatter = ISO8601DateFormatter()
                let date = dateFormatter.date(from:self.payDate)!
                self.lblDataBillPayDate.text = date.completeHumanReadableTime().inLocalizedLanguage() ?? "..."

                self.lblDataBillPayAmount.text = self.payAmount.inRialFormat()  + " " + "CURRENCY".localizedNew ?? "..."
                self.lblDataBillNumber.text = self.billNumber.inLocalizedLanguage() ?? "..."
                self.lblDataBillPayNumber.text = self.payNumber.inLocalizedLanguage() ?? "..."

                self.tableView.reloadData()

            } else {
                print(errorMessage)
            }
        })
    }
    private func getImageOfBill(userPhoneNumber: String!) {
        IGApiElectricityBill.shared.getImageOfBill(billNumber: (billNumber.inEnglishNumbersNew()), phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            SMLoading.hideLoadingPage()
            if success {
                self.saveBase64StringToImage((response?.data?.document)!,ext: response?.data?.ext)
            } else {
                print(errorMessage)
            }
        })

    }
    private func saveBase64StringToImage(_ base64String: String,ext: String? = ".pdf") {

        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
            //handle error when getting documents URL
            return
        }

        //name your file however you prefer
        documentsURL.appendPathComponent(self.billNumber + self.payDate + ext!)

        do {
            try convertedData.write(to: documentsURL)
        } catch {
            //handle write error here
        }

        //if you want to get a quick output of where your
        //file was saved from the simulator on your machine
        //just print the documentsURL and go there in Finder
        print(documentsURL)
        //let path =  Bundle.main.path(forResource: "Guide", ofType: ".pdf")!
         let dc = UIDocumentInteractionController(url: documentsURL)
         dc.delegate = self
         dc.presentPreview(animated: true)

    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.navigationController!
    }

    // MARK: - Actions
    @IBAction func didTapOnPayButton(_ sender: UIButton) {
    }
    @IBAction func didTapOnAddEditBill(_ sender: UIButton) {
        let addEditVC = IGElecAddEditBillTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        addEditVC.hidesBottomBarWhenPushed = true
        addEditVC.billNumber = (billNumber.inEnglishNumbersNew())
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

        let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)

        addEditVC.userNumber = userPhoneNumber
        addEditVC.canEditBill = self.canEditBill
        addEditVC.billTitle = self.billTittle
        self.navigationController!.pushViewController(addEditVC, animated:true)

    }
    @IBAction func didTapOnShowImage(_ sender: UIButton) {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %lld", IGAppManager.sharedManager.userID()!)
        let userInDb = realm.objects(IGRegisteredUser.self).filter(predicate).first

        let userPhoneNumber =  validaatePhoneNUmber(phone: userInDb?.phone)
        SMLoading.showLoadingPage(viewcontroller: self)
        self.getImageOfBill(userPhoneNumber: userPhoneNumber)
    }
    @IBAction func didTapOnBranchingInfo(_ sender: UIButton) {
        let branchingInfo = IGElecBillBranchingInfoTableViewController.instantiateFromAppStroryboard(appStoryboard: .ElectroBill)
        branchingInfo.hidesBottomBarWhenPushed = true
        branchingInfo.billNUmber = (billNumber.inEnglishNumbersNew())
        self.navigationController!.pushViewController(branchingInfo, animated:true)

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

    
}
